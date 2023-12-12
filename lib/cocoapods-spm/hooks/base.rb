require "cocoapods-spm/config"
require "cocoapods-spm/def/podfile"
require "cocoapods-spm/def/spec"

module Pod
  module SPM
    class Hook
      include Config::Mixin

      def initialize(context)
        @context = context
      end

      def sandbox
        @context.sandbox
      end

      def pods_project
        @context.pods_project
      end

      def config
        Config.instance
      end

      def run; end
    end
  end
end
