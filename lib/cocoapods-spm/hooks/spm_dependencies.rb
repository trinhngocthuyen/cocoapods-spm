require "cocoapods-spm/hooks/base"
require "cocoapods-spm/dependencies_resolver"

module Pod
  module SPM
    class SpmDependenciesHook < Hook
      def run
        resolver.resolve
        return unless resolver.spm_pkgs

        add_spm_pkg_refs_to_project
        add_spm_products_to_targets
        update_import_paths
        pods_project.save
      end

      private

      def resolver
        @resolver ||= DependenciesResolver.new(podfile, @context.umbrella_targets)
      end

      def spm_pkg_refs
        @spm_pkg_refs ||= {}
      end

      def add_spm_pkg_refs_to_project
        @spm_pkg_refs = resolver.spm_pkgs.to_h do |pkg|
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
          resolver.spm_dependencies_by_target[target.name].to_a.each do |dep|
            pkg_ref = spm_pkg_refs[dep.pkg.name]
            product_ref = pkg_ref.create_pkg_product_dependency_ref(dep.product)
            target.package_product_dependencies << product_ref
          end
        end
      end

      def podfile
        Pod::Config.instance.podfile
      end

      def update_import_paths
        # Workaround: Currently, update the swift import paths of the base/Pods project
        # to make it effective across all pod targets
        pods_project.build_configurations.each do |config|
          to_add = '${SYMROOT}/${CONFIGURATION}${EFFECTIVE_PLATFORM_NAME}'
          import_paths = config.build_settings['SWIFT_INCLUDE_PATHS'] || ['$(inherited)']
          import_paths << to_add unless import_paths.include?(to_add)
          config.build_settings['SWIFT_INCLUDE_PATHS'] = import_paths
        end
      end
    end
  end
end
