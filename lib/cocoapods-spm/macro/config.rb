module Pod
  module SPM
    module MacroConfigMixin
      include Config::Mixin

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

      def metadata
        @metadata ||= MacroMetadata.for_pod(name)
      end
    end
  end
end
