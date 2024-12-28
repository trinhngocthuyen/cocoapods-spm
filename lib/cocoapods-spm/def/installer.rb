module Pod
  class Installer
    module InstallerMixin
      def native_targets
        projects_to_integrate.flat_map(&:targets)
      end

      def projects_to_integrate
        [pods_project] + pod_target_subprojects
      end
    end

    include InstallerMixin
  end
end
