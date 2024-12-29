require "cocoapods-spm/macro/prebuilder"

module Pod
  class Command
    class Spm < Command
      class Macro < Spm
        class Prebuild < Macro
          self.summary = "Prebuild macros"
          def self.options
            [
              ["--all", "Prebuild all macros"],
              ["--macros=foo", "Macros to prebuild, separated by comma (,)"],
              ["--config=foo", "Config (debug/release) to prebuild macros"],
            ].concat(super)
          end

          def initialize(argv)
            super
            update_cli_config(
              all: argv.flag?("all"),
              macros: argv.option("macros", "").split(","),
              config: argv.option("config"),
              dont_prebuild_macros: false,
              dont_prebuild_macros_if_exist: false
            )
          end

          def run
            verify_podfile_exists!
            spm_config.macros.each do |name|
              SPM::MacroPrebuilder.new(name: name).run
            end
          end
        end
      end
    end
  end
end
