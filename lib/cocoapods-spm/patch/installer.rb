require_relative "../metadata"
require_relative "../macro/pod_installer"

module Pod
  class Installer
    include SPM::Config::Mixin

    alias origin_create_pod_installer create_pod_installer
    def create_pod_installer(pod_name)
      if macro_pods.include?(pod_name)
        macro_pod_installer = MacroPodInstaller.new(
          sandbox,
          podfile,
          specs_for_pod(pod_name),
          can_cache: installation_options.clean?
        )
        pod_installers << macro_pod_installer
        macro_pod_installer
      else
        origin_create_pod_installer(pod_name)
      end
    end
  end
end
