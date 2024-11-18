require "cocoapods-spm/swift/package/description"

module Pod
  module SPM
    class MacroMetadata < Swift::PackageDescription
      def self.for_pod(name)
        path = Config.instance.macro_root_dir / name / "metadata.json"
        unless path.exist?
          UI.message "Will fetch macro #{name} because its metadata does not exist at #{path}"
          require "cocoapods-spm/macro/fetcher"
          MacroFetcher.new(name: name, can_cache: true).run
        end
        from_file(path)
      end
    end
  end
end
