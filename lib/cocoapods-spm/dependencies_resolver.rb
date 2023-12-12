module Pod
  module SPM
    class DependenciesResolver
      attr_reader :spm_pkgs, :spm_dependencies_by_target

      def initialize(podfile, umbrella_targets)
        @podfile = podfile
        @umbrella_targets = umbrella_targets
        @spm_pkgs = []
        @spm_dependencies_by_target = {}
      end

      def resolve
        resolve_spm_pkgs
        resolve_spm_dependencies_by_target
      end

      private

      def resolve_spm_pkgs
        @spm_pkgs = @podfile.target_definition_list.flat_map(&:spm_pkgs).uniq
      end

      def resolve_spm_dependencies_by_target
        resolve_dependencies_for_targets
        resolve_dependencies_for_umbrella_targets
        @spm_dependencies_by_target.values.flatten.each { |d| d.pkg = spm_pkg_for(d.name) }
      end

      def resolve_dependencies_for_targets
        specs = @umbrella_targets.flat_map(&:specs).uniq
        specs.each do |spec|
          @spm_dependencies_by_target[spec.name] = spec.spm_dependencies
        end
      end

      def resolve_dependencies_for_umbrella_targets
        @umbrella_targets.each do |target|
          spm_dependencies = target.specs.flat_map(&:spm_dependencies)
          @spm_dependencies_by_target[target.cocoapods_target_label] = merge_spm_dependencies(spm_dependencies)
        end

        common_spm_pkgs = @podfile.root_target_definitions.flat_map(&:spm_pkgs)
        @podfile.target_definition_list.reject(&:abstract?).each do |target|
          existing = @spm_dependencies_by_target[target.label].to_a
          spm_dependencies = (common_spm_pkgs + target.spm_pkgs).flat_map(&:to_dependencies)
          @spm_dependencies_by_target[target.label] = merge_spm_dependencies(existing + spm_dependencies)
        end
      end

      def merge_spm_dependencies(deps)
        deps_by_name = Hash.new { |h, k| h[k] = [] }
        deps.each { |d| deps_by_name[d.name] << d }
        deps_by_name.each do |name, ds|
          deps_by_name[name] = ds.uniq { |d| [d.name, d.product] }
        end
        deps_by_name.values.flatten
      end

      def spm_pkg_for(name)
        @_spm_pkgs_by_name ||= @spm_pkgs.to_h { |pkg| [pkg.name, pkg] }
        @_spm_pkgs_by_name[name]
      end
    end
  end
end
