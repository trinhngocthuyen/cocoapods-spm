require "cocoapods-spm/swift/package/base"

module Pod
  module Swift
    class PackageDescription < PackageDescriptionBaseObject
      include SPM::Config::Mixin
      autoload :Dependency, "cocoapods-spm/swift/package/dependency"
      autoload :Target, "cocoapods-spm/swift/package/target"
      autoload :Product, "cocoapods-spm/swift/package/product"

      def self.from_dir(dir)
        raw = `swift package dump-package --package-path #{dir.shellescape}`
        from_s(raw)
      end

      def src_dir
        @src_dir ||= begin
          path = raw.fetch("packageKind", {}).fetch("root", [])[0]
          Pathname.new(path) unless path.nil?
        end
      end

      def artifacts_dir
        spm_config.pkg_artifacts_dir / slug
      end

      def slug
        src_dir.nil? ? name : src_dir.basename.to_s
      end

      def dependencies
        @dependencies ||= convert_field("dependencies", Dependency)
      end

      def targets
        @targets ||= convert_field("targets", Target)
      end

      def products
        @products ||= convert_field("products", Product)
      end

      def targets_of_product(name)
        matched_products = products.select { |p| p.name == name }
        dynamic = matched_products.any?(&:dynamic?)
        matched_products
          .flat_map do |p|
            targets.select { |t| p.target_names.include?(t.name) }.map do |t|
              t.dup_with_attrs(dynamic: dynamic, product_name: name)
            end
          end
      end

      def macro_impl_name
        targets.find(&:macro?)&.name
      end

      def use_default_xcode_linking?
        return @use_default_xcode_linking unless @use_default_xcode_linking.nil?

        pkg = pod_config.podfile.spm_pkgs.find { |t| t.name == name }
        @use_default_xcode_linking = pkg&.use_default_xcode_linking?
      end

      private

      def convert_field(name, type)
        raw.fetch(name, []).flat_map { |h| type.new(h, parent: self) }
      end
    end
  end
end
