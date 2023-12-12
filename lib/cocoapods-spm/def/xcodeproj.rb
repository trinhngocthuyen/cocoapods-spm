require "xcodeproj"

module Pod
  module SPM
    module Object
      module PackageReferenceMixin
        attr_accessor :name

        def create_pkg_product_dependency_ref(product)
          ref = project.new(BaseObject::XCSwiftPackageProductDependency)
          ref.package = self
          ref.product_name = product
          ref
        end
      end

      BaseObject = Xcodeproj::Project::Object

      class XCRemoteSwiftPackageReference < BaseObject::XCRemoteSwiftPackageReference
        include PackageReferenceMixin
      end

      class XCLocalSwiftPackageReference < BaseObject::XCLocalSwiftPackageReference
        include PackageReferenceMixin
      end

      class XCSwiftPackageProductDependency < BaseObject::XCSwiftPackageProductDependency
      end
    end
  end
end
