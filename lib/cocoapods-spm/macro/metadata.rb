require "cocoapods-spm/swift/package/description"

module Pod
  module SPM
    class MacroMetadata < Swift::PackageDescription
      def self.for_pod(name)
        from_file(Config.instance.macro_root_dir / name / "metadata.json")
      end
    end
  end
end
