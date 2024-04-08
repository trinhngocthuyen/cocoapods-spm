require "cocoapods-spm/executables"
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
          generate_metadata
          resolve_product_deps
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

        def generate_metadata
          @metadata_cache ||= {}
          @spm_analyzer.spm_pkgs.each do |pkg|
            raw = Dir.chdir(spm_config.pkg_checkouts_dir / pkg.name) do
              `swift package dump-package`
            end
            (spm_config.pkg_metadata_dir / "#{pkg.name}.json").write(raw)
            @metadata_cache[pkg.name] = Metadata.from_s(raw)
          end
        end

        def resolve_product_deps
          @spm_analyzer.spm_dependencies_by_target.values.flatten.uniq(&:name).each do |dep|
            # metadata = metadata_of(dep.name)
            # TODO: Resolve product dependencies
          end
        end

        def metadata_of(pkg)
          @metadata_cache[pkg]
        end
      end
    end
  end
end
