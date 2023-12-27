require "cocoapods-spm/metadata"

module Pod
  module SPM
    class MacroPrebuilder
      include Config::Mixin

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
        macro_dir / ".prebuilt"
      end

      def metadata_path
        macro_dir / "metadata.json"
      end

      def generate_metadata
        raise "Package.swift not exist in #{macro_downloaded_dir}" \
          unless (macro_downloaded_dir / "Package.swift").exist?

        cmd =
          "cd #{macro_downloaded_dir} " \
          "&& swift package dump-package " \
          "> #{metadata_path.relative_path_from(macro_downloaded_dir)}"
        `#{cmd}`
        @metadata = Metadata.from_file(metadata_path)
      end

      def prebuild_macro_impl
        return if spm_config.dont_prebuild_macros?

        config = spm_config.macro_config
        impl_module_name = @metadata.macro_impl_name
        return if spm_config.dont_prebuild_macros_if_exist? && (macro_prebuilt_dir / config / impl_module_name).exist?

        UI.puts "Building macro implementation: #{impl_module_name} (#{config})...".green
        `cd #{macro_downloaded_dir} && swift build -c #{config} --product #{impl_module_name}`
        (macro_prebuilt_dir / config).mkpath
        FileUtils.copy_entry(
          macro_downloaded_dir / ".build" / config / impl_module_name,
          macro_prebuilt_dir / config / impl_module_name
        )
      end
    end
  end
end
