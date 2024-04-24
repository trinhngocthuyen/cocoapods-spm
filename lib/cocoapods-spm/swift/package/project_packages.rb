require "cocoapods-spm/swift/package/description"

module Pod
  module Swift
    class ProjectPackages
      def initialize(options = {})
        @src_dir = options[:src_dir]
        raise Informative, "src_dir must not be nil" if @src_dir.nil?

        @json_dir = options[:write_json_to_dir]
        @pkg_desc_cache = {}
        load
      end

      def resolve_recursive_targets_of(pkg_name, product_name)
        @recursive_targets_cache ||= {}
        return @recursive_targets_cache[product_name] if @recursive_targets_cache.key(product_name)

        res = []
        to_visit = pkg_desc_of(pkg_name).targets_of_product(product_name)
        until to_visit.empty?
          target = to_visit.pop
          res << target
          to_visit += target.resolve_dependencies(@pkg_desc_cache)
        end
        @recursive_targets_cache[product_name] = res.uniq(&:name)
      end

      def pkg_desc_of(name)
        return @pkg_desc_cache[name] if @pkg_desc_cache.key?(name)

        raise Informative, "Package description of `#{name}` does not exist!"
      end

      private

      def load
        @src_dir.glob("*").each do |dir|
          next if dir.glob("Package*.swift").empty?

          raw = Dir.chdir(dir) { `swift package dump-package` }
          pkg_desc = PackageDescription.from_s(raw)
          write_data = lambda do |name|
            @pkg_desc_cache[name] = pkg_desc
            (@json_dir / "#{name}.json").write(raw) unless @json_dir.nil?
          end

          pkg_name = pkg_desc.name
          pkg_slug = dir.basename.to_s
          write_data.call(pkg_name)
          write_data.call(pkg_slug) unless pkg_name == pkg_slug
        end
      end
    end
  end
end
