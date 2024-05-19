require "cocoapods-spm/macro/metadata"

module Pod
  module SPM
    class MacroPrebuilder
      include Config::Mixin
      include Executables

      attr_reader :name

      def initialize(options = {})
        @name = options[:name]
      end

      def run
        generate_metadata
        prebuild_macro_impl
      end

      def macro_downloaded_dir
        spm_config.macro_downloaded_root_dir / name
      end

      def macro_dir
        @macro_dir ||= spm_config.macro_root_dir / name
      end

      def macro_prebuilt_dir
        spm_config.macro_prebuilt_root_dir / name
      end

      def metadata_path
        macro_dir / "metadata.json"
      end

      def generate_metadata
        raise "Package.swift not exist in #{macro_downloaded_dir}" \
          unless (macro_downloaded_dir / "Package.swift").exist?

        raw = Dir.chdir(macro_downloaded_dir) { `swift package dump-package` }
        metadata_path.write(raw)
        @metadata = MacroMetadata.from_s(raw)
      end

      def prebuild_macro_impl
        return if spm_config.dont_prebuild_macros?

        config = spm_config.macro_config
        impl_module_name = @metadata.macro_impl_name
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
