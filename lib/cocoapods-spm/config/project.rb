require "cocoapods-spm/helpers/path"

module Pod
  module SPM
    class Config
      module ProjectConfigMixin
        def project_config
          ProjectConfig.instance
        end
      end

      class ProjectConfig
        def self.instance
          @instance ||= ProjectConfig.new
        end

        def workspace
          @workspace ||= Pod::Config.instance.podfile.defined_in_file.parent.glob("*.xcworkspace").first
        end

        def scheme
          workspace.parent.glob("*.xcodeproj/**/*.xcscheme").first.basename(".xcscheme")
        end

        def default_derived_data_path
          @default_derived_data_path ||= begin
            raw = `xcodebuild -showBuildSettings -workspace #{workspace.shellescape} -scheme #{scheme.shellescape}`
            Pathname(raw[/BUILD_DIR = (.*)/, 1]).parent.parent
          end
        end
      end
    end
  end
end
