require "cocoapods-spm/config/spm"
require "cocoapods-spm/config/pod"
require "cocoapods-spm/config/project"

module Pod
  module SPM
    class Config
      module Mixin
        include ProjectConfigMixin
        include PodConfigMixin
        include SPMConfigMixin
      end
    end
  end
end
