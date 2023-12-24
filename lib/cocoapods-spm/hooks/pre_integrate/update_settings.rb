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
            update_targets: lambda do |target, _, _|
              { "OTHER_LDFLAGS" => linker_flags_for(target) }
            end
          )
        end

        def linker_flags_for(target)
          spm_deps = @spm_analyzer.spm_dependencies_by_target[target.to_s].to_a
          framework_flags = spm_deps.select(&:dynamic?).map { |d| "-framework \"#{d.product}\"" }
          framework_flags << '-F"${PODS_CONFIGURATION_BUILD_DIR}/PackageFrameworks"' unless framework_flags.empty?
          library_flags = spm_deps.reject(&:dynamic?).map { |d| "-l\"#{d.product}.o\"" }
          library_flags << '-L"${PODS_CONFIGURATION_BUILD_DIR}"' unless library_flags.empty?
          framework_flags + library_flags
        end

        def update_swift_include_paths
          return unless @spm_analyzer.spm_pkgs

          # For macro packages
          perform_settings_update(
            update_targets: lambda do |_, _, _|
              { "SWIFT_INCLUDE_PATHS" => "$(PODS_CONFIGURATION_BUILD_DIR)" }
            end
          )
        end
      end
    end
  end
end
