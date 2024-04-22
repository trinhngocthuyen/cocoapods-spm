module Pod
  module SPM
    class Resolver
      class ProductDependencyResolver
        require "cocoapods-spm/resolver/product"

        include Config::Mixin

        def initialize(podfile, result)
          @podfile = podfile
          @result = result
        end

        def resolve
          generate_metadata
          resolve_dynamic_products
          resolve_binary_targets
          resolve_headers_path_by_target
          resolve_product_deps
        end

        private

        def generate_metadata
          spm_config.pkg_checkouts_dir.glob("*").each do |dir|
            next if dir.glob("Package*.swift").empty?

            raw = Dir.chdir(dir) { `swift package dump-package` }
            metadata = Metadata.from_s(raw)
            write_metadata = lambda do |name|
              (spm_config.pkg_metadata_dir / "#{name}.json").write(raw)
              @result.metadata_cache[name] = metadata
            end

            pkg_name = metadata["name"]
            pkg_slug = dir.basename.to_s
            write_metadata.call(pkg_name)
            write_metadata.call(pkg_slug) unless pkg_name == pkg_slug
          end
        end

        def resolve_dynamic_products
          @dynamic_products ||= Set.new
          @result.metadata_cache.each_value do |metadata|
            metadata.products.each do |h|
              library_types = h.fetch("type", {}).fetch("library", [])
              @dynamic_products << h["name"] if library_types.include?("dynamic")
            end
          end
        end

        def resolve_binary_targets
          @binary_basenames_by_target ||= {}
          @result.metadata_cache.each_value do |metadata|
            metadata.targets.each do |h|
              next unless h["type"] == "binary"

              target_name = h["name"]
              @binary_basenames_by_target[target_name] = @result.binary_basename_of(
                metadata.name, target_name
              )
            end
          end
        end

        def resolve_headers_path_by_target
          @headers_path_by_product ||= {}
          @result.metadata_cache.each_value do |metadata|
            metadata.targets.each do |h|
              @headers_path_by_product[h["name"]] = h["publicHeadersPath"] if h.key?("publicHeadersPath")
            end
          end
        end

        # TODO: To be refactored
        # rubocop:disable Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
        def resolve_product_deps
          @result.spm_dependencies_by_target.values.flatten.uniq(&:product).each do |dep|
            next if dep.pkg.use_default_xcode_linking?

            verify_product_exists_in_pkg(dep.pkg.name, dep.product)

            to_visit =
              target_names_of_product(
                dep.product, @result.metadata_of(dep.pkg.name)
              )
              .map { |t| [t, dep.pkg.name] }
            until to_visit.empty?
              target_name, pkg_name = to_visit.pop
              @result.spm_products[dep.product] ||= []
              @result.spm_products[dep.product] << create_product(
                pkg_name, target_name, dep.product
              )

              to_visit +=
                @result
                .metadata_of(dep.pkg.name)
                .targets
                .find { |h| h["name"] == target_name }
                .to_h
                .fetch("dependencies", [])
                .flat_map { |h| dep_hash_to_target_names(h, pkg_name) }
            end
          end
        end
        # rubocop:enable Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity

        def verify_product_exists_in_pkg(pkg, name)
          return unless @result.metadata_of(pkg).products.find { |h| h["name"] == name }.nil?

          raise Informative, "Package `#{pkg}` does not contain product named `#{name}`"
        end

        def create_product(pkg, target_name, product_name)
          linkage = @dynamic_products.include?(product_name) ? :dynamic : :static
          Product.new(
            pkg: pkg,
            name: linkage == :dynamic ? product_name : target_name,
            linkage: linkage,
            headers_path: @headers_path_by_product[target_name],
            binary_basename: @binary_basenames_by_target[target_name]
          )
        end

        def target_names_of_product(name, metadata)
          metadata
            .products
            .select { |h| h["name"] == name }
            .flat_map { |h| h.fetch("targets", {}) }
        end

        # TODO: To be refactored
        # rubocop:disable Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
        def dep_hash_to_target_names(hash, pkg_name)
          type = ["byName", "target", "product"].find { |k| hash.key?(k) }
          name = hash[type][0] unless type.nil?
          pkg_name = hash["product"][1] if hash.key?("product")
          return [[name, pkg_name]] if hash.key?("target")

          metadata = @result.metadata_of(pkg_name)
          return target_names_of_product(name, metadata).map { |t| [t, pkg_name] } if hash.key?("product")

          return unless hash.key?("byName")
          # Could be either a target or a product
          return [[name, pkg_name]] if metadata.targets.any? { |h| h["name"] == name }

          target_names_of_product(name, metadata).map { |t| [t, pkg_name] }
        end
        # rubocop:enable Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
      end
    end
  end
end
