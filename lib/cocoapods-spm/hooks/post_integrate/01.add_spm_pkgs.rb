require "cocoapods-spm/hooks/base"
require "cocoapods-spm/resolver"

module Pod
  module SPM
    class Hook
      class AddSpmPkgs < Hook
        def run
          return if @spm_resolver.result.spm_pkgs.empty?

          projects_to_integrate.compact.each do |project|
            spm_pkg_refs = {}
            project.targets.each do |target|
              @spm_resolver.result.spm_dependencies_for(target).each do |dep|
                pkg_ref = dep.pkg.create_pkg_ref(project)
                target_dep_ref = pkg_ref.create_target_dependency_ref(dep.product)
                target.dependencies << target_dep_ref
                target.package_product_dependencies << target_dep_ref.product_ref if dep.pkg.use_default_xcode_linking?
                spm_pkg_refs.store(dep.pkg.name, pkg_ref)
              end
            end
            spm_pkg_refs.each_value do |pkg_ref|
              project.root_object.package_references << pkg_ref
            end
            project.save
          end
        end
      end
    end
  end
end
