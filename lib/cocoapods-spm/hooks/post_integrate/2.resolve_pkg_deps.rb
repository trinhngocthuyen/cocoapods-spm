require "cocoapods-spm/hooks/base"
require "cocoapods-spm/installer/analyzer"

module Pod
  module SPM
    class Hook
      class ResolvePkgDeps < Hook
        def run
          return if @spm_analyzer.spm_pkgs.empty?

          xcodebuild_resolve_package_deps
        end

        private

        def xcodebuild_resolve_package_deps
          workspace = podfile.defined_in_file.parent.glob("*.xcworkspace").first
          scheme = workspace.parent.glob("*.xcodeproj/**/*.xcscheme").first.basename(".xcscheme")
          system([
            "xcodebuild",
            "-resolvePackageDependencies",
            "-workspace", workspace.shellescape,
            "-scheme", scheme.shellescape,
          ].join(" "))
        end
      end
    end
  end
end
