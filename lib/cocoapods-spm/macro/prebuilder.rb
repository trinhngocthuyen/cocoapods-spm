require "cocoapods-spm/macro/metadata"
require_relative "config"

module Pod
  module SPM
    class MacroPrebuilder
      include MacroConfigMixin
      include Executables

      attr_reader :name

      def initialize(options = {})
        @name = options[:name]
      end

      def run
        prebuild_macro_impl
      end

      def prebuild_macro_impl
        return if spm_config.dont_prebuild_macros?

        config = spm_config.macro_config
        impl_module_name = metadata.macro_impl_name
        prebuilt_binary = macro_prebuilt_dir / "#{impl_module_name}-#{config}"
        return if spm_config.dont_prebuild_macros_if_exist? && prebuilt_binary.exist?

        UI.section "Building macro implementation: #{impl_module_name} (#{config})...".green do
          Dir.chdir(macro_downloaded_dir) do
            swift! ["build", "-c", config, "--product", impl_module_name]
          end
        end

        prebuilt_binary.parent.mkpath
        FileUtils.copy_entry(
          macro_downloaded_dir / ".build" / config / impl_module_name,
          prebuilt_binary
        )
      end
    end
  end
end
