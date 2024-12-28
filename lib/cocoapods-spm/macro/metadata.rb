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

      def platforms
        raw["platforms"].to_h { |ds| [ds["platformName"], ds["version"]] }
      end

      def platform_build_settings
        ds = {
          "ios" => "IPHONEOS_DEPLOYMENT_TARGET",
          "macos" => "MACOSX_DEPLOYMENT_TARGET",
          "tvos" => "TVOS_DEPLOYMENT_TARGET",
          "watchos" => "WATCHOS_DEPLOYMENT_TARGET",
          "visionos" => "XROS_DEPLOYMENT_TARGET",
          "driverkit" => "DRIVERKIT_DEPLOYMENT_TARGET",
        }
        platforms.transform_keys { |k| ds[k] }.reject { |k, _| k.nil? }
      end
    end
  end
end
