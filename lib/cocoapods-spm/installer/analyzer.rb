module Pod
  class Installer
    class SPMAnalyzer
      attr_reader :spm_pkgs, :spm_dependencies_by_target

      def initialize(podfile, umbrella_targets)
        @podfile = podfile
        @umbrella_targets = umbrella_targets
        @spm_pkgs = []
        @spm_dependencies_by_target = {}
      end

      def analyze
        analyze_spm_pkgs
        analyze_spm_dependencies_by_target
      end

      def spm_dependencies_for(target)
        @spm_dependencies_by_target[target.to_s]
      end

      private

      def analyze_spm_pkgs
        @spm_pkgs = @podfile.target_definition_list.flat_map(&:spm_pkgs).uniq
      end

      def analyze_spm_dependencies_by_target
        analyze_dependencies_for_targets
        analyze_dependencies_for_umbrella_targets
        @spm_dependencies_by_target.values.flatten.each { |d| d.pkg = spm_pkg_for(d.name) }
      end

      def analyze_dependencies_for_targets
        specs = @umbrella_targets.flat_map(&:specs).uniq
        specs.each do |spec|
          @spm_dependencies_by_target[spec.name] = spec.spm_dependencies
        end
      end

      def analyze_dependencies_for_umbrella_targets
        @umbrella_targets.each do |target|
          spm_dependencies = target.specs.flat_map(&:spm_dependencies)
          @spm_dependencies_by_target[target.to_s] = merge_spm_dependencies(spm_dependencies)
        end

        @podfile.spm_pkgs_by_aggregate_target.each do |target, pkgs|
          existing = @spm_dependencies_by_target[target].to_a
          spm_dependencies = pkgs.flat_map(&:to_dependencies)
          @spm_dependencies_by_target[target] = merge_spm_dependencies(existing + spm_dependencies)
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
