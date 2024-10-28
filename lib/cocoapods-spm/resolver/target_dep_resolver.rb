module Pod
  module SPM
    class Resolver
      class TargetDependencyResolver
        def initialize(podfile, aggregate_targets, result)
          @podfile = podfile
          @aggregate_targets = aggregate_targets
          @result = result
        end

        def resolve
          resolve_spm_pkgs
          resolve_spm_dependencies_by_target
        end

        private

        def resolve_spm_pkgs
          @result.spm_pkgs = @podfile.target_definition_list.flat_map(&:spm_pkgs).uniq
        end

        def resolve_spm_dependencies_by_target
          resolve_dependencies_for_targets
          resolve_dependencies_for_aggregate_targets
          @result.spm_dependencies_by_target.values.flatten.each { |d| d.pkg = spm_pkg_for(d.name) }
        end

        def resolve_dependencies_for_targets
          specs = @aggregate_targets.flat_map(&:specs).uniq
          specs.each do |spec|
            @result.spm_dependencies_by_target[spec.name] = spec.spm_dependencies
          end
        end

        def resolve_dependencies_for_aggregate_targets
          @aggregate_targets.each do |target|
            spm_dependencies = target.specs.flat_map(&:spm_dependencies)
            @result.spm_dependencies_by_target[target.to_s] = merge_spm_dependencies(spm_dependencies)
          end

          @podfile.spm_pkgs_by_aggregate_target.each do |target, pkgs|
            existing = @result.spm_dependencies_by_target[target].to_a
            spm_dependencies = pkgs.flat_map(&:to_dependencies)
            @result.spm_dependencies_by_target[target] = merge_spm_dependencies(existing + spm_dependencies)
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
          @_spm_pkgs_by_name ||= @result.spm_pkgs.to_h { |pkg| [pkg.name, pkg] }
          @_spm_pkgs_by_name[name]
        end
      end
    end
  end
end
