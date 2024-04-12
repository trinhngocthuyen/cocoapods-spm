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

        def resolve_product_deps
          @result.spm_dependencies_by_target.values.flatten.uniq(&:name).each do |dep|
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
          end
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
          if hash.key?("byName")
            name = hash["byName"][0]
            pkg = metadata["name"]
          elsif hash.key?("product")
            name, pkg = hash["product"]
          elsif hash.key?("target")
            # TODO: Handle this
          end
          create_product(pkg, name)
        end

        def create_product(pkg, name)
          Product.new(pkg: pkg, name: name, linkage: linkage_of(pkg, name))
        end

        def linkage_of(pkg, name)
          @cache_linkage ||= {}
          return @cache_linkage[name] if @cache_linkage.key?(name)

          @cache_linkage[name] =
            if @result
               .metadata_of(pkg)
               .products
               .find { |h| h["name"] == name }
               .to_h
               .fetch("type", {})
               .fetch("library", [])
               .include?("dynamic")
              :dynamic
            else
              :static
            end
        end
      end
    end
  end
end
