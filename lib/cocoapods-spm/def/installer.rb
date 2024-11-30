module Pod
  class Installer
    def native_targets
      pods_project.targets + pod_target_subprojects.flat_map(&:targets)
    end
  end
end
