module Pod
  module SPM
    class Resolver
      class Result
        include Config::Mixin

        ATTRS = {
          :spm_pkgs => [],
          :spm_dependencies_by_target => {},
          :spm_products => {},
          :metadata_cache => {},
        }.freeze

        class WritableResult < Result
          ATTRS.each_key { |x| attr_accessor x }

          def to_read_only
            Result.new(ATTRS.to_h { |x| [x, instance_variable_get("@#{x}")] })
          end
        end

        ATTRS.each_key { |x| attr_reader x }

        def initialize(options = {})
          ATTRS.each do |k, v|
            instance_variable_set("@#{k}", options[k] || v)
          end
        end

        def metadata_of(name)
          return @metadata_cache[name] if @metadata_cache.key?(name)

          raise Informative, "Metadata of `#{name}` does not exist"
        end

        def binary_basename_of(pkg_name, target_name)
          pkg_slug = @spm_pkgs.find { |pkg| pkg.name == pkg_name }.slug
          dir = spm_config.pkg_artifacts_dir / pkg_slug / target_name
          paths = dir.glob("*.xcframework/*/*.{a,framework}")
          paths.empty? ? target_name : paths[0].basename.to_s
        end

        def spm_pkgs_for(target)
          spm_dependencies_for(target).map(&:pkg).uniq(&:name)
        end

        def spm_dependencies_for(target)
          @spm_dependencies_by_target[target.to_s].to_a
        end

        def spm_products_for(target)
          spm_dependencies_for(target).flat_map { |d| @spm_products[d.product].to_a }.uniq(&:name)
        end

        def linker_flags_for(target)
          (
            spm_products_for(target).flat_map(&:linker_flags) +
            spm_pkgs_for(target).flat_map(&:linker_flags)
          ).uniq
        end
      end
    end
  end
end
