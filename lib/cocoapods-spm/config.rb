module Pod
  module SPM
    class Config
      attr_accessor :dsl_config

      def initialize
        @dsl_config = {}
      end

      def self.instance
        @instance ||= Config.new
      end
    end
  end
end
