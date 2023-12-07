require_relative "prebuild"

module Pod
  class Command
    class Spm < Command
      include Pod::SPM::Config::Mixin

      self.abstract_command = true

      def update_cli_config(options)
        spm_config.cli_config.merge!(options)
      end
    end
  end
end
