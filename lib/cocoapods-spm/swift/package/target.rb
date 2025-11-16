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

        def public_headers_path_expr
          @public_headers_path_expr ||= public_headers_path.to_s.sub(
            root.checkouts_dir.to_s,
            "${SOURCE_PACKAGES_CHECKOUTS_DIR}"
          )
        end

        def header_search_path_arg
          "\"#{public_headers_path_expr}\"" unless public_headers_path.nil?
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

        def modulemap_path
          @modulemap_path ||= public_headers_path&.glob("*.modulemap")&.first
        end

        def clang_modulemap_path_expr
          return "#{public_headers_path_expr}/#{modulemap_path.basename}" unless modulemap_path.nil?

          "${GENERATED_MODULEMAP_DIR}/#{name}.modulemap" unless binary?
        end

        def clang_modulemap_arg
          "-fmodule-map-file=\"#{clang_modulemap_path_expr}\"" unless clang_modulemap_path_expr.nil?
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
            next find_dependency_targets(
              pkg_desc_cache,
              hash[type][0],
              pkg_name: hash.key?("product") ? hash["product"][1] : nil,
              type: type
            )
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

          # macos is called osx in Cocoapods.
          platform_name = platform.to_s == 'osx' ? 'macos' : platform.to_s
          condition["platformNames"].include?(platform_name)
        end

        def find_dependency_targets(pkg_desc_cache, name, pkg_name: nil, type: nil)
          pkg_desc = pkg_desc_cache[pkg_name || self.pkg_name]
          find_by_target = lambda do
            pkg_desc.targets.select { |t| t.name == name }
          end

          find_by_product = lambda do
            pkg_desc.targets_of_product(name)
          end

          find_by_name = lambda do
            pkg_desc_cache.values.flat_map(&:targets).select { |t| t.name == name }
          end

          return find_by_target.call if type == "target"
          return find_by_product.call if type == "product"
          return find_by_name.call
        end
      end
    end
  end
end
