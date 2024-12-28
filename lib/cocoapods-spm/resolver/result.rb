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
          filtered_dependencies = @spm_dependencies_by_target[spec_name_of(target)]&.reject do |dep|
            dep.pkg&.should_exclude_from_target?(target.name)
          end
          filtered_dependencies.to_a
        end

        def spm_targets_for(target, exclude_default_xcode_linking: true)
          targets = spm_dependencies_for(target).flat_map do |d|
            project_pkgs.resolve_recursive_targets_of(d.pkg.name, d.product, platform: target.platform.name)
          end.uniq(&:name)
          return targets.reject(&:use_default_xcode_linking?) if exclude_default_xcode_linking

          targets
        end

        def linker_flags_for(target)
          (
            spm_targets_for(target).flat_map(&:linker_flags) +
            spm_pkgs_for(target).flat_map(&:linker_flags)
          ).uniq
        end

        private

        def spec_name_of(target)
          # In case of multi-platforms, the target name might contains the platform (ex. Logger-iOS, Logger-macOS)
          # We need to strip the platform suffix out
          return target.name if @spm_dependencies_by_target.key?(target.name)
          return target.root_spec.name if target.is_a?(Pod::PodTarget)
          return target.name if target.is_a?(Pod::AggregateTarget)

          cmps = target.name.split("-")
          return cmps[...-1].join("-") if ["iOS", "macOS", "watchOS", "tvOS", "visionOS"].include?(cmps[-1])

          target.name
        end
      end
    end
  end
end
