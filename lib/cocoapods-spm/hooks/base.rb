require "cocoapods-spm/config"
require "cocoapods-spm/def/podfile"
require "cocoapods-spm/def/spec"

module Pod
  module SPM
    class Hook
      include Config::Mixin

      def initialize(context, options = {})
        @context = context
        @options = options
        @spm_analyzer = options[:spm_analyzer]
        @analysis_result = options[:analysis_result]
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

      def self.run_hooks(phase, context, options)
        Dir["#{__dir__}/#{phase}/*.rb"].sort.each do |f|
          require f
          id = File.basename(f, ".*")
          cls_name = "Pod::SPM::Hook::#{id.camelize}"
          UI.message "Running hook: #{cls_name}"
          cls_name.constantize.new(context, options).run
        end
      end
    end
  end
end
