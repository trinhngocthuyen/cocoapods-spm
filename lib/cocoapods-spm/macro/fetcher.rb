require "cocoapods-spm/macro/metadata"
require_relative "config"

module Pod
  module SPM
    class MacroFetcher
      include MacroConfigMixin

      attr_reader :name

      def initialize(options = {})
        @name = options[:name]
        @specs_by_platform = options[:specs_by_platform]
        @can_cache = options[:can_cache]
        @podfile = Pod::Config.instance.podfile
      end

      def run
        UI.puts "Fetching macro #{name}...".magenta
        download_macro_source
        macro_dir = spm_config.macro_root_dir / name
        macro_downloaded_dir = spm_config.macro_downloaded_root_dir / name
        FileUtils.copy_entry(
          macro_downloaded_dir / "Sources" / name,
          macro_dir / "Sources" / name
        )
        generate_metadata
      end

      private

      def generate_metadata
        raise "Package.swift not exist in #{macro_downloaded_dir}" \
          unless (macro_downloaded_dir / "Package.swift").exist?

        raw = Dir.chdir(macro_downloaded_dir) { `swift package dump-package` }
        metadata_path.write(raw)
      end

      def download_macro_source
        @specs_by_platform ||= @podfile.root_target_definitions.to_h do |definition|
          spec = Pod::Spec.from_file(spm_config.macro_root_dir / name / "#{name}.podspec")
          [definition.platform, [spec]]
        end

        # When `can_cache` is true, PodSourceDownloader only keeps the contents
        # according to its `source_files` declared in the podspec.
        # However, we wish to keep all contents (including Package.swift...).
        # --> We alter the spec when downloading the source.
        altered_specs_by_platform = @specs_by_platform.to_h do |platform, specs|
          altered_specs = specs.map do |spec|
            spec.with { |s| s.source_files = "**/*" }
          end
          [platform, altered_specs]
        end
        downloader = Pod::Installer::PodSourceDownloader.new(
          spm_config.macro_downloaded_sandbox,
          @podfile,
          altered_specs_by_platform,
          can_cache: @can_cache
        )
        downloader.download!
      end
    end
  end
end
