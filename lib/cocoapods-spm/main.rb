require "cocoapods-spm/config"
require "cocoapods-spm/dsl"
require "cocoapods-spm/specification"

module Pod
  module SPM
    class Hook
      def initialize(context)
        @context = context
      end

      def sandbox
        @context.sandbox
      end

      def pods_project
        @context.pods_project
      end

      def config
        Config.instance
      end

      def all_specs
        @all_specs ||= @context.umbrella_targets.flat_map(&:specs).uniq
      end

      def run
        all_specs.each do |spec|
          if spec.spm_dependencies
            target = pods_project.targets.find { |t| t.name == spec.name }
            add_spm_dependencies(target, spec.spm_dependencies)
          end
        end
        update_import_paths
        pods_project.save
      end

      private

      def add_spm_dependencies(target, dependencies)
        dependencies.each do |data|
          pkg = pkg_from_data(data)
          data[:products].each do |product|
            ref = pods_project.new(Xcodeproj::Project::Object::XCSwiftPackageProductDependency)
            ref.package = pkg
            ref.product_name = product
            target.package_product_dependencies << ref
          end
          pods_project.root_object.package_references << pkg
        end
      end

      def update_import_paths
        # Workaround: Currently, update the swift import paths of the base/Pods project
        # to make it effective across all pod targets
        pods_project.build_configurations.each do |config|
          to_add = '${SYMROOT}/${CONFIGURATION}${EFFECTIVE_PLATFORM_NAME}'
          import_paths = config.build_settings['SWIFT_INCLUDE_PATHS'] || ['$(inherited)']
          import_paths << to_add unless import_paths.include?(to_add)
          config.build_settings['SWIFT_INCLUDE_PATHS'] = import_paths
        end
      end

      def pkg_from_data(data)
        if data[:requirement]
          pkg = pods_project.new(Xcodeproj::Project::Object::XCRemoteSwiftPackageReference)
          pkg.repositoryURL = data[:url]
          pkg.requirement = data[:requirement]
        else
          pkg = pods_project.new(Xcodeproj::Project::Object::XCLocalSwiftPackageReference)
          pkg.relative_path = data[:relative_path]
        end
        pkg
      end
    end
  end
end
