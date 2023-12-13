require "cocoapods-spm/hooks/base"
require "cocoapods-spm/metadata"

module Pod
  module SPM
    class Hook
      class UpdateMacroSettings < Hook
        def run
          update_other_swift_flags
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
          perform_settings_update(
            update_targets: lambda do |_, _, config|
              { "OTHER_SWIFT_FLAGS" => other_swift_flags_by_config[config] }
            end
          )
        end
      end
    end
  end
end
