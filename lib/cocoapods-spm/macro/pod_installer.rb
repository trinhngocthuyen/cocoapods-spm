require_relative "../specification"
require_relative "prebuilder"

module Pod
  class Installer
    class MacroPodInstaller < PodSourceInstaller
      include Pod::SPM::Config::Mixin

      def install!
        install_macro_pod!
        super
      end

      private

      def prebuilder
        @prebuilder ||= Pod::SPM::MacroPrebuilder.new(name)
      end

      def install_macro_pod!
        prepare_macro_source
        prebuilder.run
      end

      def prepare_macro_source
        download_macro_source
        macro_dir = spm_config.macro_root_dir / name
        macro_downloaded_dir = spm_config.macro_downloaded_root_dir / name
        FileUtils.copy_entry(
          macro_downloaded_dir / "Sources" / name,
          macro_dir / "Sources" / name
        )
      end

      def download_macro_source
        # When `can_cache` is true, PodSourceDownloader only keeps the contents
        # according to its `source_files` declared in the podspec.
        # However, we wish to keep all contents (including Package.swift...).
        # --> We alter the spec when downloading the source.
        altered_specs_by_platform = specs_by_platform.to_h do |platform, specs|
          altered_specs = specs.map do |spec|
            spec.with { |s| s.source_files = "**/*" }
          end
          [platform, altered_specs]
        end
        downloader = PodSourceDownloader.new(
          spm_config.macro_downloaded_sandbox,
          podfile,
          altered_specs_by_platform,
          :can_cache => can_cache?
        )
        downloader.download!
      end
    end
  end
end
