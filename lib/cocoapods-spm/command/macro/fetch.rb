require "cocoapods-spm/macro/fetcher"

module Pod
  class Command
    class Spm < Command
      class Macro < Spm
        class Fetch < Macro
          self.summary = "Fetch macros"
          def self.options
            [
              ["--all", "Prebuild all macros"],
              ["--macros=foo", "Macros to prebuild, separated by comma (,)"],
            ].concat(super)
          end

          def initialize(argv)
            super
            update_cli_config(
              all: argv.flag?("all"),
              macros: argv.option("macros", "").split(",")
            )
          end

          def run
            verify_podfile_exists!
            spm_config.macros.each do |name|
              SPM::MacroFetcher.new(name: name, can_cache: true).run
            end
          end
        end
      end
    end
  end
end
