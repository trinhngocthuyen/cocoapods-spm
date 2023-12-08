require_relative "prebuild"
require_relative "fetch"

module Pod
  class Command
    class Spm < Command
      include Pod::SPM::Config::Mixin

      self.summary = "Working with SPM"
      self.abstract_command = true

      def update_cli_config(options)
        spm_config.cli_config.merge!(options)
      end
    end
  end
end
