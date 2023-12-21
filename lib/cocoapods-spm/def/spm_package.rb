require "cocoapods-spm/def/xcodeproj"
require "cocoapods-spm/def/spm_dependency"

module Pod
  module SPM
    class Package
      attr_reader :name, :requirement, :url, :relative_path, :linkage

      def initialize(name, options = {})
        @name = name
        @options = options
        @requirement = requirement_from(options)
        @url = options[:url]
        @relative_path = options[:relative_path]
        @linkage = options[:linkage]
      end

      def inspect
        "#<#{self.class} name=#{name}>"
      end

      def local?
        @relative_path != nil
      end

      def to_dependencies
        if (products = @options[:products])
          products.map { |product| Dependency.new(@name, product: product, pkg: self) }
        else
          [Dependency.new(@name, pkg: self)]
        end
      end

      def create_pkg_ref(project)
        cls = local? ? Object::XCLocalSwiftPackageReference : Object::XCRemoteSwiftPackageReference
        ref = project.new(cls)
        ref.name = name
        if local?
          ref.relative_path = relative_path
        else
          ref.repositoryURL = url
          ref.requirement = requirement
        end
        ref
      end

      private

      def requirement_from(options)
        if options[:requirement]
          options[:requirement]
        elsif (version = options.delete(:version))
          { :kind => "exactVersion", :version => version }
        elsif (branch = options.delete(:branch))
          { :kind => "branch", :branch => branch }
        elsif (revision = options.delete(:commit))
          { :kind => "revision", :revision => revision }
        elsif options[:relative_path]
          nil
        else
          raise "Missing requirement for SPM package: #{name}"
        end
      end
    end
  end
end
