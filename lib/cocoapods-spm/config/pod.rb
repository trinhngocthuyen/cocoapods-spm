require "cocoapods-spm/helpers/path"

module Pod
  module SPM
    class Config
      module PodConfigMixin
        include PathMixn

        def pod_config
          Pod::Config.instance
        end
      end
    end
  end
end
