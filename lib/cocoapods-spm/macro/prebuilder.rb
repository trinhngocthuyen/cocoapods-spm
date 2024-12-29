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
        if spm_config.dont_prebuild_macros_if_exist? && prebuilt_binary.exist?
          return UI.message "Macro binary exists at #{prebuilt_binary} -> Skip prebuilding macro"
        end

        UI.section "Building macro implementation: #{impl_module_name} (#{config})...".green do
          swift! ["--version"]
          swift! [
            "build",
            "-c", config,
            "--product", impl_module_name,
            "--package-path", macro_downloaded_dir,
            "--scratch-path", macro_scratch_dir,
          ]
          # Workaround: When building a macro, the debug.yaml under the scratch dir contains some corrupted info,
          # causing the following failure when building the next macro:
          #     No target named 'OrcamImpl-debug.exe' in build description
          # Idk what this file is for, but deleting it helps
          macro_scratch_dir.glob("*.yaml").each { |p| p.delete if p.exist? }
        end

        prebuilt_binary.parent.mkpath
        macro_downloaded_build_config_dir = macro_scratch_dir / config
        macro_build_binary_file_path = macro_downloaded_build_config_dir / impl_module_name
        unless macro_build_binary_file_path.exist?
          macro_build_binary_file_path = macro_downloaded_build_config_dir / "#{impl_module_name}-tool"
        end
        FileUtils.copy_entry(
          macro_build_binary_file_path,
          prebuilt_binary
        )
      end
    end
  end
end
