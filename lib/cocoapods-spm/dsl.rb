require "cocoapods-spm/config"

module Pod
  class Podfile
    module DSL
      def config_xcconfig_hooks(options)
        Pod::SPM::Config.instance.dsl_config = options
      end
    end
  end
end
