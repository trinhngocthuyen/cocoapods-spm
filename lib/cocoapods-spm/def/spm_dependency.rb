module Pod
  module SPM
    class Dependency
      attr_reader :name, :product
      attr_accessor :pkg

      def initialize(name, options = {}, product: nil, pkg: nil)
        cmps = name.split("/")
        raise "Invalid dependency `#{name}`" if cmps.count > 2

        @name = cmps.first
        @product = product || cmps.last
        @options = options
        @pkg = pkg
      end

      def inspect
        "#<#{self.class} name=#{name} product=#{product} pkg=#{pkg}>"
      end
    end
  end
end
