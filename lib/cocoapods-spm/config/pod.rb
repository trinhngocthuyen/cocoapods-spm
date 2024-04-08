module Pod
  module SPM
    class Config
      module PodConfigMixin
        def pod_config
          Pod::Config.instance
        end
      end
    end
  end
end
