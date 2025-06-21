require "cocoapods-spm/config"
require "cocoapods-spm/def/podfile"
require "cocoapods-spm/def/spec"
require "cocoapods-spm/macro/metadata"

module Pod
  module SPM
    class Hook
      include Config::Mixin
      include Installer::InstallerMixin

      def initialize(context, options = {})
        @context = context
        @options = options
        @spm_resolver = options[:spm_resolver]
        @analysis_result = options[:analysis_result]
      end

      def sandbox
        @context.sandbox
      end

      def pods_project
        @context.pods_project
      end

      def pod_targets
        @analysis_result.pod_targets
      end

      def aggregate_targets
        @analysis_result.targets
      end

      def pod_target_subprojects
        @context.pod_target_subprojects
      end

      def user_build_configurations
        @user_build_configurations ||= (pod_targets + aggregate_targets)[0].user_build_configurations
      end

      def config
        Config.instance
      end

      def podfile
        pod_config.podfile
      end

      def run; end

      def self.run_hooks(phase, context, options)
        Dir["#{__dir__}/#{phase}/*.rb"].sort.each do |f|
          require f
          id = File.basename(f, ".*").split(".").last
          cls_name = "Pod::SPM::Hook::#{id.camelize}"
          UI.message "- Running hook: #{cls_name}" do
            cls_name.constantize.new(context, options).run
          end
        end
      end

      def perform_settings_update(
        update_targets: nil,
        update_pod_targets: nil,
        update_aggregate_targets: nil
      )
        proc = lambda do |update, target, setting, config|
          return if update.nil?

          hash = update.call(target, setting, config)
          setting.xcconfig.merge!(hash)
          setting.generate.merge!(hash)
          Installer::Xcode::PodsProjectGenerator::TargetInstallerHelper.update_changed_file(
            setting, target.xcconfig_path(config)
          )
        end

        pod_targets.each do |target|
          target.build_settings.each do |config, setting|
            proc.call(update_targets, target, setting, config)
            proc.call(update_pod_targets, target, setting, config)
          end
          next unless target.is_a?(PodTarget)

          (target.test_specs + target.app_specs).each do |spec|
            target_wrapper = Target::NonLibrary.new(underlying: target, spec: spec)
            target.build_settings.each_key do |config|
              setting = target.build_settings_for_spec(spec, :configuration => config)
              proc.call(update_targets, target_wrapper, setting, config)
            end
          end
        end

        aggregate_targets.each do |target|
          target.user_build_configurations.each_key do |config|
            setting = target.build_settings(config)
            proc.call(update_targets, target, setting, config)
            proc.call(update_aggregate_targets, target, setting, config)
          end
        end
      end

      def macro_metadata_for_pod(name)
        return nil unless spm_config.all_macros.include?(name)

        @macro_metadata_cache ||= {}
        @macro_metadata_cache[name] = MacroMetadata.for_pod(name) unless @macro_metadata_cache.key?(name)
        @macro_metadata_cache[name]
      end

      def pod_name_of_target(name)
        target = @analysis_result.pod_targets.find { |x| x.name == name }
        target.nil? ? name : target.pod_name
      end
    end
  end
end
