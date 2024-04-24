module Pod
  module SPM
    class Resolver
      class Result
        include Config::Mixin

        ATTRS = {
          :spm_pkgs => [],
          :spm_dependencies_by_target => {},
          :project_pkgs => nil,
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

        def spm_pkgs_for(target)
          spm_dependencies_for(target).map(&:pkg).uniq(&:name)
        end

        def spm_dependencies_for(target)
          @spm_dependencies_by_target[target.to_s].to_a
        end

        def spm_targets_for(target)
          spm_dependencies_for(target).flat_map do |d|
            project_pkgs.resolve_recursive_targets_of(d.pkg.name, d.product)
          end.uniq(&:name)
        end

        def linker_flags_for(target)
          (
            spm_targets_for(target).flat_map(&:linker_flags) +
            spm_pkgs_for(target).flat_map(&:linker_flags)
          ).uniq
        end
      end
    end
  end
end
