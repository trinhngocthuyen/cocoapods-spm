require "cocoapods-spm/command/macro"

module Pod
  class Command
    class Spm < Command
      include SPM::Config::Mixin

      self.summary = "Working with SPM"
      self.abstract_command = true

      def update_cli_config(options)
        spm_config.cli_config.merge!(options)
      end
    end
  end
end
