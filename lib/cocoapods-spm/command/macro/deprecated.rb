module Pod
  class Command
    class Spm < Command
      def self.bind_command(cls)
        Class.new(Spm) do
          define_method(:cls) { cls }

          self.summary = "[Deprecated] #{cls.summary}"

          def self.options
            cls.options
          end

          def initialize(argv)
            name = self.class.name.demodulize.downcase
            warn "[DEPRECATION] `pod spm #{name}` is deprecated. Please use `pod spm macro #{name}` instead.".yellow
            @_binded = cls.new(argv)
            super
          end

          def validate!
            @_binded.validate!
          end

          def run
            @_binded.run
          end
        end
      end

      Fetch = bind_command(Macro::Fetch)
      Prebuild = bind_command(Macro::Prebuild)
    end
  end
end
