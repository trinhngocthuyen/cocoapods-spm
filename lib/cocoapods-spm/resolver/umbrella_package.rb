module Pod
  module SPM
    class UmbrellaPackage
      include Config::Mixin

      def initialize(podfile)
        @podfile = podfile
        @spm_pkgs = @podfile.target_definition_list.flat_map(&:spm_pkgs).uniq
      end

      def prepare
        generate_pkg_swift
        swift_pkg_resolve
        self
      end

      private

      def generate_pkg_swift
        swift_tools_version = "5.7"
        dependencies = @spm_pkgs.map do |pkg|
          # https://developer.apple.com/documentation/packagedescription/package/dependency
          tail = case pkg.requirement[:kind]
                 when "exactVersion"
                   "exact: \"#{pkg.requirement[:version]}\""
                 when "branch"
                   "branch: \"#{pkg.requirement[:branch]}\""
                 when "revision"
                   "revision: \"#{pkg.requirement[:revision]}\""
                 else
                   # TODO: Handle this
                   "todo: \"handle this\""
                 end
          ".package(url: \"#{pkg.url}\", #{tail})"
        end

        package_content = <<~HEREDOC
          // swift-tools-version:#{swift_tools_version}
          import PackageDescription

          let package = Package(
            name: "_umbrella_",
            dependencies: [
              #{dependencies.join(",\n    ")}
            ]
          )
        HEREDOC
        (spm_config.pkg_umbrella_dir / "Package.swift").write(package_content)
      end

      def swift_pkg_resolve
        Dir.chdir(spm_config.pkg_umbrella_dir) { `swift package resolve` }
      end
    end
  end
end
