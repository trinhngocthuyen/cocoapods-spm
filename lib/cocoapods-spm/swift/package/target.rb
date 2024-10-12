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

        def sources_path
          @sources_path ||= begin
            path = raw["path"] || "Sources/#{name}"
            root.src_dir / path
          end
        end

        def header_search_path_arg
          return nil if public_headers_path.nil?

          path = public_headers_path.to_s.sub(root.checkouts_dir.to_s, "${SOURCE_PACKAGES_CHECKOUTS_DIR}")
          "\"#{path}\""
        end

        def public_headers_path
          res = sources_path / raw["publicHeadersPath"] if raw.key?("publicHeadersPath")
          res = implicit_public_headers if res.nil?
          res
        end

        def implicit_public_headers
          path = sources_path / "include"
          path unless path.glob("**/*.h*").empty?
        end

        def use_generated_modulemap?
          return false if public_headers_path.nil?

          # If there exists module.modulemap, it'll be auto picked up during compilation
          true if public_headers_path.glob("module.modulemap").empty?
        end

        def clang_modulemap_arg
          return nil unless use_generated_modulemap?

          "-fmodule-map-file=\"${GENERATED_MODULEMAP_DIR}/#{name}.modulemap\""
        end

        def resources
          res = raw.fetch("resources", []).flat_map { |h| Resources.new(h, parent: self) }
          res = implicit_resources if res.empty?
          res
        end

        def implicit_resources
          target_sources_path = raw["path"] || "Sources/#{name}"
          target_sources_path = root.src_dir / target_sources_path

          # Refer to the following link for the implicit resources
          # https://developer.apple.com/documentation/xcode/bundling-resources-with-a-swift-package#Add-resource-files
          patterns = [
            "*.xcassets",
            "*.xib",
            "*.storyboard",
            "*.xcdatamodeld",
            "*.lproj",
          ]
          return [] if patterns.all? { |p| target_sources_path.glob(p).empty? }

          [Resources.new({}, parent: self)]
        end

        def linker_flags
          return ["-framework \"#{framework_name}\""] if dynamic?
          return ["-l\"#{name}.o\""] unless binary?

          case binary_basename
          when /(\S+)\.framework/ then ["-framework \"#{$1}\""]
          when /lib(\S+)\.(a|dylib)/ then ["-l\"#{$1}\""]
          when /(\S+\.(a|dylib))/ then ["\"${PODS_CONFIGURATION_BUILD_DIR}/#{$1}\""]
          else []
          end
        end

        def resolve_dependencies(pkg_desc_cache, platform: nil)
          raw.fetch("dependencies", []).flat_map do |hash|
            type = ["byName", "target", "product"].find { |k| hash.key?(k) }
            if type.nil?
              raise Informative, "Unexpected dependency type. Must be either `byName`, `target`, or `product`."
            end
            next [] unless match_platform?(hash[type][-1], platform)

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

        def xcframework
          @xcframework ||= begin
            path = (root.artifacts_dir / name).glob("*.xcframework")[0]
            Xcode::XCFramework.new(name, path.realpath) unless path.nil?
          end
        end

        def binary_basename
          return nil unless binary?

          @binary_basename ||= begin
            xcframework_dir ||= (root.artifacts_dir / name).glob("*.xcframework")[0]
            xcframework_dir ||= root.src_dir / raw["path"] if raw.key?("path")
            paths = xcframework_dir.glob("*/*.{a,framework}")
            UI.warn "Cannot detect binary_basename for #{name}" if paths.empty?
            paths[0].basename.to_s unless paths.empty?
          end
        end

        def use_default_xcode_linking?
          root.use_default_xcode_linking?
        end

        private

        def match_platform?(condition, platform)
          # Consider matching if there's no condition
          return true if condition.nil? || !condition.key?("platformNames")

          condition["platformNames"].include?(platform.to_s)
        end
      end
    end
  end
end
