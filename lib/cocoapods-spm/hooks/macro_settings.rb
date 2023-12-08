require_relative "base"

module Pod
  module SPM
    class MacroSettingsHook < Hook
      def run
        update_other_swift_flags(@context.pods_project, "..")
        update_other_swift_flags(@context.umbrella_targets[0].user_project, ".")
      end

      def update_other_swift_flags(project, path_prefix)
        project.build_configurations.each do |config|
          flags = config.build_settings["OTHER_SWIFT_FLAGS"] || "$(inherited)"
          macro_pods.each_key do |name|
            metadata = Metadata.for_pod(name)
            impl_module_name = metadata.macro_impl_name
            plugin_executable_path =
              "#{path_prefix}/.spm.pods/#{name}/.prebuilt/#{config.to_s.downcase}/" \
              "#{impl_module_name}##{impl_module_name}"
            to_add = "-load-plugin-executable #{plugin_executable_path}"
            flags += " #{to_add}" unless flags.include?(to_add)
          end
          config.build_settings["OTHER_SWIFT_FLAGS"] = flags
        end
        project.save
      end
    end
  end
end
