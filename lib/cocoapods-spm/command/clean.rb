module Pod
  class Command
    class Spm < Command
      class Clean < Spm
        self.summary = "Clean caches"
        def self.options
          [
            ["--all", "Clean all"],
            ["--macros", "Clean macros"],
            ["--packages", "Clean packages"],
          ].concat(super)
        end

        def initialize(argv)
          super
          @clean_all = argv.flag?("all")
          @clean_macros = argv.flag?("macros")
          @clean_pkgs = argv.flag?("packages")
        end

        def run
          to_clean = []
          to_clean << spm_config.pkg_root_dir if @clean_pkgs
          to_clean << spm_config.macro_root_dir if @clean_macros
          to_clean << spm_config.root_dir if @clean_all
          to_clean.each { |dir| dir.rmtree if dir.exist? }
        end
      end
    end
  end
end
