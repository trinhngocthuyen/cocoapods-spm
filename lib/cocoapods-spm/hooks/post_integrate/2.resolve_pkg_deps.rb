require "cocoapods-spm/executables"
require "cocoapods-spm/hooks/base"
require "cocoapods-spm/resolver"

module Pod
  module SPM
    class Hook
      class ResolvePkgDeps < Hook
        def run
          return if @spm_resolver.spm_pkgs.empty?

          xcodebuild_resolve_package_deps
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

        def generate_metadata
          @metadata_cache ||= {}
          @spm_resolver.spm_pkgs.each do |pkg|
            raw = Dir.chdir(spm_config.pkg_checkouts_dir / pkg.name) do
              `swift package dump-package`
            end
            (spm_config.pkg_metadata_dir / "#{pkg.name}.json").write(raw)
            @metadata_cache[pkg.name] = Metadata.from_s(raw)
          end
        end

        def resolve_product_deps
          @spm_resolver.spm_dependencies_by_target.values.flatten.uniq(&:name).each do |dep|
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
