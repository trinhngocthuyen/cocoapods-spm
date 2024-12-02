module Pod
  module SPM
    class Config
      module SPMConfigMixin
        def spm_config
          Config.instance
        end

        def macro_pods
          pod_config.podfile.macro_pods
        end

        def local_macro_pod?(name)
          !local_macro_pod_dir(name).nil?
        end

        def local_macro_pod_dir(name)
          opts = macro_pods.fetch(name, {})
          return Path(opts[:podspec]).dirname if opts.key?(:podspec)

          Pathname(opts[:path]) if opts.key?(:path)
        end
      end

      attr_accessor :dsl_config, :cli_config

      def initialize
        @dsl_config = {
          :dont_prebuild_macros => false,
          :dont_prebuild_macros_if_exist => true,
        }
        @cli_config = {}
      end

      def self.instance
        @instance ||= Config.new
      end

      def merged_config
        @dsl_config.merge(@cli_config)
      end

      def dont_prebuild_macros?
        merged_config[:dont_prebuild_macros]
      end

      def dont_prebuild_macros_if_exist?
        merged_config[:dont_prebuild_macros_if_exist]
      end

      def macro_config
        merged_config[:config] || merged_config[:default_macro_config] || "debug"
      end

      def all_macros
        @all_macros ||= Pod::Config.instance.podfile.macro_pods.keys
      end

      def macros
        merged_config[:all] ? all_macros : (merged_config[:macros] || [])
      end

      def root_dir
        @root_dir ||= Pathname(".spm.pods")
      end

      def pkg_root_dir
        @pkg_root_dir ||= prepare_dir(root_dir / "packages")
      end

      def macro_root_dir
        @macro_root_dir ||= prepare_dir(root_dir / "macros")
      end

      def macro_downloaded_root_dir
        macro_root_dir / ".downloaded"
      end

      def macro_prebuilt_root_dir
        macro_root_dir / ".prebuilt"
      end

      def macro_downloaded_sandbox
        @macro_downloaded_sandbox ||= Sandbox.new(macro_downloaded_root_dir)
      end

      def pkg_umbrella_dir
        @pkg_umbrella_dir ||= prepare_dir(pkg_root_dir / ".umbrella")
      end

      def pkg_checkouts_dir
        pkg_umbrella_dir / ".build" / "checkouts"
      end

      def pkg_artifacts_dir
        pkg_umbrella_dir / ".build" / "artifacts"
      end

      def pkg_metadata_dir
        @pkg_metadata_dir ||= prepare_dir(pkg_root_dir / "metadata")
      end

      private

      def prepare_dir(dir)
        dir.mkpath
        dir
      end
    end
  end
end
