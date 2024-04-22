require "cocoapods-spm/def/xcodeproj"
require "cocoapods-spm/def/spm_dependency"

module Pod
  module SPM
    class Package
      attr_reader :name, :requirement, :url, :relative_path, :linking_opts

      def initialize(name, options = {})
        @name = name
        @_options = options
        @relative_path = nil
        @linkage = nil
        @url = nil
        @requirement = nil
        @linking_opts = {}
        parse_options(options)
      end

      def parse_options(options)
        @url = options[:url] || options[:git]
        @relative_path = relative_path_from(options)
        @requirement = requirement_from(options)
        @linking_opts = options[:linking] || {}
      end

      def slug
        @slug ||= File.basename(@url || @relative_path, ".*")
      end

      def absolute_path
        (Pathname("Pods") / relative_path).realpath.to_s
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
        "#<#{self.class} #{name}>"
      end

      alias to_s inspect

      def local?
        @relative_path != nil
      end

      def use_default_xcode_linking?
        @linking_opts.fetch(:use_default_xcode_linking, false)
      end

      def linker_flags
        @linking_opts[:linker_flags] || []
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
