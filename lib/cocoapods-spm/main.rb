require "cocoapods-spm/config"
require "cocoapods-spm/dsl"

module Pod
  module SPM
    class Hook
      def initialize(context)
        @context = context
      end

      def sandbox
        @context.sandbox
      end

      def config
        Config.instance
      end

      def run
        # TODO: Implement me
      end
    end
  end
end
