require_relative "../macro/fetcher"

module Pod
  class Command
    class Spm < Command
      class Fetch < Spm
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
          spm_config.macros.each do |name|
            Pod::SPM::MacroFetcher.new(name: name, can_cache: true).run
          end
        end
      end
    end
  end
end
