require "cocoapods-spm/swift/package/base"

module Pod
  module Swift
    class PackageDescription
      class Resources < PackageDescriptionBaseObject
        def name
          "#{pkg_name}_#{parent.name}"
        end

        def built_resource_path
          "${PODS_CONFIGURATION_BUILD_DIR}/#{name}.bundle"
        end
      end
    end
  end
end
