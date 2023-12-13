require "cocoapods-spm/hooks/base"
require "cocoapods-spm/metadata"

module Pod
  module SPM
    class Hook
      class UpdateLinkerFlags < Hook
        def run
          update_linker_flags
        end

        private

        def update_linker_flags
          aggregate_targets.each do |target|
            spm_deps = @spm_analyzer.spm_dependencies_by_target[target.to_s].to_a
            flags = spm_deps.map { |d| "-l\"#{d.product}.o\"" }
            next if flags.empty?

            target.user_build_configurations.each_key do |config|
              setting = target.build_settings(config)
              update_setting!(setting, "OTHER_LDFLAGS" => flags)
            end
          end
        end
      end
    end
  end
end
