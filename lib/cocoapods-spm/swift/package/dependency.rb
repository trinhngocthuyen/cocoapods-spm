require "cocoapods-spm/swift/package/base"

module Pod
  module Swift
    class PackageDescription
      class Dependency < PackageDescriptionBaseObject
        def local?
          raw.key?("fileSystem")
        end

        def slug
          hash["identity"]
        end

        def path
          hash["path"]
        end

        private

        def hash
          raw.values.flatten[0] || {}
        end
      end
    end
  end
end
