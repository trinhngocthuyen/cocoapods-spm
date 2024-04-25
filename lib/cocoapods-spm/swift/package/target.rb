require "cocoapods-spm/swift/package/base"

module Pod
  module Swift
    class PackageDescription
      autoload :Resources, "cocoapods-spm/swift/package/resources"

      class Target < PackageDescriptionBaseObject
        def type
          raw["type"]
        end

        def macro?
          type == "macro"
        end

        def binary?
          return @binary unless @binary.nil?

          @binary = type == "binary"
        end

        def dynamic?
          @dynamic
        end

        def framework_name
          @product_name || name
        end

        def public_headers_path
          raw["publicHeadersPath"]
        end

        def clang_modulemap_arg
          return nil if public_headers_path.nil?

          "-fmodule-map-file=\"${GENERATED_MODULEMAP_DIR}/#{name}.modulemap\""
        end

        def resources
          raw.fetch("resources", []).flat_map { |h| Resources.new(h, parent: self) }
        end

        def linker_flags
          return ["-framework \"#{framework_name}\""] if dynamic?
          return ["-l\"#{name}.o\""] unless binary?

          case binary_basename
          when /(\S+)\.framework/ then ["-framework \"#{$1}\""]
          when /lib(\S+)\.a/ then ["-library \"#{$1}\""]
          when /(\S+\.a)/ then ["\"${PODS_CONFIGURATION_BUILD_DIR}/#{$1}\""]
          else []
          end
        end

        def resolve_dependencies(pkg_desc_cache)
          raw.fetch("dependencies", []).flat_map do |hash|
            type = ["byName", "target", "product"].find { |k| hash.key?(k) }
            if type.nil?
              raise Informative, "Unexpected dependency type. Must be either `byName`, `target`, or `product`."
            end

            name = hash[type][0]
            pkg_name = hash.key?("product") ? hash["product"][1] : self.pkg_name
            pkg_desc = pkg_desc_cache[pkg_name]
            find_by_target = -> { pkg_desc.targets.select { |t| t.name == name } }
            find_by_product = -> { pkg_desc.targets_of_product(name) }
            next find_by_target.call if hash.key?("target")
            next find_by_product.call if hash.key?("product")

            # byName, could be either a target or a product
            next find_by_target.call || find_by_product.call
          end
        end

        def built_framework_path
          "${BUILT_PRODUCTS_DIR}/PackageFrameworks/#{framework_name}.framework"
        end

        def binary_basename
          return nil unless binary?

          @binary_basename ||= begin
            paths = (root.artifacts_dir / name).glob("*.xcframework/*/*.{a,framework}")
            paths[0].basename.to_s unless paths.empty?
          end
        end
      end
    end
  end
end
