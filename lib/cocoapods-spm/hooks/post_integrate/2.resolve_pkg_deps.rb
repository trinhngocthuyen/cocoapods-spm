require "cocoapods-spm/hooks/base"
require "cocoapods-spm/installer/analyzer"

module Pod
  module SPM
    class Hook
      class ResolvePkgDeps < Hook
        def run
          return if @spm_analyzer.spm_pkgs.empty?

          xcodebuild_resolve_package_deps
          create_symlink_to_checkouts
        end

        private

        def xcodebuild_resolve_package_deps
          system([
            "xcodebuild",
            "-resolvePackageDependencies",
            "-workspace", project_config.workspace.shellescape,
            "-scheme", project_config.scheme.shellescape,
          ].join(" "))
        end

        def create_symlink_to_checkouts
          src_dir = project_config.default_derived_data_path / "SourcePackages" / "checkouts"
          dst_dir = spm_config.pkg_checkouts_dir
          dst_dir.delete if dst_dir.exist?
          UI.message "Create symlink: #{src_dir} -> #{dst_dir}"
          File.symlink(src_dir, dst_dir)
        end
      end
    end
  end
end
