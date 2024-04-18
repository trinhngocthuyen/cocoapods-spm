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
          @binary_targets ||= Set.new
          @result.metadata_cache.each_value do |metadata|
            metadata.targets.each do |h|
              @binary_targets << h["name"] if h["type"] == "binary"
            end
          end
        end

        def resolve_headers_path_by_target
          @headers_path_by_product ||= {}
          @result.metadata_cache.each_value do |metadata|
            metadata.targets.each do |h|
              next unless h.key?("publicHeadersPath")

              metadata.product_names_of_target(h["name"]).each do |name|
                @headers_path_by_product[name] = h["publicHeadersPath"]
              end
            end
          end
        end

        def resolve_product_deps
          @result.spm_dependencies_by_target.values.flatten.uniq(&:product).each do |dep|
            next if dep.pkg.use_default_xcode_linking?

            verify_product_exists_in_pkg(dep.pkg.name, dep.product)
            product = create_product(dep.pkg.name, dep.product)
            recursive_products_of(product)
          end
        end

        def verify_product_exists_in_pkg(pkg, name)
          return unless @result.metadata_of(pkg).products.find { |h| h["name"] == name }.nil?

          raise Informative, "Package `#{pkg}` does not contain product named `#{name}`"
        end

        def recursive_products_of(product)
          products = [product] + direct_products_of(product).flat_map do |child|
            [child] + recursive_products_of(child)
          end.uniq(&:name)
          @result.spm_products[product.name] = products
          products
        end

        def direct_products_of(product)
          metadata = @result.metadata_of(product.pkg)
          metadata
            .products
            .find { |h| h["name"] == product.name }
            .to_h
            .fetch("targets", [product.name])
            .flat_map do |t|
              metadata
                .targets
                .find { |h| h["name"] == t }
                .fetch("dependencies", [])
                .map { |h| product_from_hash(h, metadata) }
            end
        end

        def product_from_hash(hash, metadata)
          type = ["byName", "target", "product"].find { |k| hash.key?(k) }
          name = hash[type][0] unless type.nil?
          pkg = metadata["name"]
          pkg = hash["product"][1] if hash.key?("product")
          create_product(pkg, name)
        end

        def create_product(pkg, name)
          Product.new(
            pkg: pkg,
            name: name,
            linkage: @dynamic_products.include?(name) ? :dynamic : :static,
            headers_path: @headers_path_by_product[name],
            binary: @binary_targets.include?(name)
          )
        end
      end
    end
  end
end
