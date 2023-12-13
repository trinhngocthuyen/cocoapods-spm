require "cocoapods-spm/hooks/base"
require "cocoapods-spm/metadata"

module Pod
  module SPM
    class Hook
      class UpdateSettings < Hook
        def run
          update_other_swift_flags
          update_swift_include_paths
          update_linker_flags
        end

        private

        def other_swift_flags_by_config
          @other_swift_flags_by_config ||= begin
            hash = user_build_configurations.keys.to_h do |config|
              flags = macro_pods.keys.map do |name|
                metadata = Metadata.for_pod(name)
                impl_module_name = metadata.macro_impl_name
                plugin_executable_path =
                  "${PODS_ROOT}/../.spm.pods/#{name}/.prebuilt/#{config.to_s.downcase}/" \
                  "#{impl_module_name}##{impl_module_name}"
                "-load-plugin-executable \"#{plugin_executable_path}\""
              end.join(" ")
              [config, flags]
            end
            user_build_configurations.each { |config, symbol| hash[symbol] = hash[config] }
            hash
          end
        end

        def update_other_swift_flags
          return unless spm_config.macros

          # For prebuilt macros
          perform_settings_update(
            update_targets: lambda do |_, _, config|
              { "OTHER_SWIFT_FLAGS" => other_swift_flags_by_config[config] }
            end
          )
        end

        def update_linker_flags
          return unless @spm_analyzer.spm_pkgs

          # For packages to work in the main target
          perform_settings_update(
            update_aggregate_targets: lambda do |target, _, _|
              spm_deps = @spm_analyzer.spm_dependencies_by_target[target.to_s].to_a
              flags = spm_deps.map { |d| "-l\"#{d.product}.o\"" }
              { "OTHER_LDFLAGS" => flags }
            end
          )
        end

        def update_swift_include_paths
          return unless @spm_analyzer.spm_pkgs

          # For macro packages
          perform_settings_update(
            update_targets: lambda do |_, _, _|
              { "SWIFT_INCLUDE_PATHS" => "${SYMROOT}/${CONFIGURATION}${EFFECTIVE_PLATFORM_NAME}" }
            end
          )
        end
      end
    end
  end
end
