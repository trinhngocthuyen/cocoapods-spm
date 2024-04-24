require "cocoapods-spm/swift/package/base"

module Pod
  module Swift
    class PackageDescription
      class Product < PackageDescriptionBaseObject
        def dynamic?
          @dynamic ||= raw.fetch("type", {}).fetch("library", []).include?("dynamic")
        end

        def target_names
          raw["targets"]
        end
      end
    end
  end
end
