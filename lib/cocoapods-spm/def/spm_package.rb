require "cocoapods-spm/def/xcodeproj"
require "cocoapods-spm/def/spm_dependency"

module Pod
  module SPM
    class Package
      attr_reader :name, :requirement, :url, :relative_path, :linkage

      def initialize(name, options = {})
        @name = name
        @_options = options
        @relative_path = nil
        @linkage = nil
        @url = nil
        @requirement = nil
        parse_options(options)
      end

      def parse_options(options)
        @url = options[:url] || options[:git]
        @linkage = options[:linkage]
        @relative_path = relative_path_from(options)
        @requirement = requirement_from(options)
      end

      def relative_path_from(options)
        if (relative_path = options[:relative_path])
          relative_path
        elsif (path = options[:path])
          path = Pathname(path).expand_path
          path.relative_path_from(File.absolute_path("Pods")).to_s
        end
      end

      def inspect
        "#<#{self.class} name=#{name}>"
      end

      def local?
        @relative_path != nil
      end

      def to_dependencies
        if (products = @_options[:products])
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
        return if @relative_path

        if (requirement = options[:requirement])
          requirement
        elsif (version = options.delete(:version) || options.delete(:tag))
          { :kind => "exactVersion", :version => version }
        elsif (branch = options.delete(:branch))
          { :kind => "branch", :branch => branch }
        elsif (revision = options.delete(:commit))
          { :kind => "revision", :revision => revision }
        else
          raise "Missing requirement for SPM package: #{name}"
        end
      end
    end
  end
end
