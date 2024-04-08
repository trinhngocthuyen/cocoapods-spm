require "cocoapods-spm/hooks/base"
require "cocoapods-spm/installer/analyzer"

module Pod
  module SPM
    class Hook
      class AddSpmPkgs < Hook
        def run
          return unless @spm_analyzer.spm_pkgs

          add_spm_pkg_refs_to_project
          add_spm_products_to_targets
          pods_project.save
        end

        private

        def spm_pkg_refs
          @spm_pkg_refs ||= {}
        end

        def add_spm_pkg_refs_to_project
          @spm_pkg_refs = @spm_analyzer.spm_pkgs.to_h do |pkg|
            pkg_ref = pkg.create_pkg_ref(pods_project)
            pods_project.root_object.package_references << pkg_ref
            [pkg.name, pkg_ref]
          end
        end

        def spm_pkgs_by_target
          @spm_pkgs_by_target ||= {}
        end

        def add_spm_products_to_targets
          pods_project.targets.each do |target|
            @spm_analyzer.spm_dependencies_by_target[target.name].to_a.each do |dep|
              pkg_ref = spm_pkg_refs[dep.pkg.name]
              target_dep_ref = pkg_ref.create_target_dependency_ref(dep.product)
              target.dependencies << target_dep_ref
            end
          end
        end
      end
    end
  end
end
