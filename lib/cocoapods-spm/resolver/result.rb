module Pod
  module SPM
    class Resolver
      class Result
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

        def spm_dependencies_for(target)
          @spm_dependencies_by_target[target.to_s].to_a
        end

        def spm_products_for(target)
          spm_dependencies_for(target).flat_map { |d| @spm_products[d.product].to_a }.uniq(&:name)
        end

        def linker_flags_for(target)
          flags = spm_dependencies_for(target).flat_map { |d| d.pkg.linker_flags }
          flags += spm_products_for(target).map do |p|
            p.linked_as_framework? ? "-framework \"#{p.name}\"" : "-l\"#{p.name}.o\""
          end
          flags.uniq
        end
      end
    end
  end
end
