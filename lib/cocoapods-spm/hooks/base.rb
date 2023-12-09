require_relative "../config"
require_relative "../dsl/podfile"
require_relative "../dsl/spec"

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

      def all_specs
        @all_specs ||= @context.umbrella_targets.flat_map(&:specs).uniq
      end

      def run; end
    end
  end
end
