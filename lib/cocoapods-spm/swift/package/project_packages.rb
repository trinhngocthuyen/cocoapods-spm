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

      def resolve_recursive_targets_of(pkg_name, product_name, platform: nil)
        @recursive_targets_cache ||= {}
        @recursive_targets_cache[platform] ||= {}
        return @recursive_targets_cache[platform][product_name] if @recursive_targets_cache[platform].key(product_name)

        res = []
        to_visit = pkg_desc_of(pkg_name).targets_of_product(product_name)
        until to_visit.empty?
          target = to_visit.pop
          res << target
          # Exclude macros as they wont be linked to the project's binary
          # https://github.com/trinhngocthuyen/cocoapods-spm/issues/107
          to_visit += target.resolve_dependencies(@pkg_desc_cache, platform: platform).reject(&:macro?)
        end
        @recursive_targets_cache[platform][product_name] = res.uniq(&:name)
      end

      def pkg_desc_of(name)
        return @pkg_desc_cache[name] if @pkg_desc_cache.key?(name)

        raise Informative, "Package description of `#{name}` does not exist!"
      end

      private

      def load
        @src_dir.glob("*").each do |dir|
          next if dir.glob("Package*.swift").empty?

          pkg_desc = PackageDescription.from_dir(dir)
          name = pkg_desc.name
          slug = dir.basename.to_s
          @pkg_desc_cache[name] = pkg_desc
          @pkg_desc_cache[slug] = pkg_desc
          next if @json_dir.nil?

          json_path = @json_dir / "#{name}.json"
          slug_json_path = @json_dir / "#{slug}.json"
          json_path.write(pkg_desc.raw.to_json)
          IOUtils.symlink(json_path, slug_json_path) unless name == slug
        end
      end
    end
  end
end
