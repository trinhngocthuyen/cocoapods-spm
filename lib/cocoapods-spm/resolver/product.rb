module Pod
  module SPM
    class Resolver
      class Product
        attr_reader :pkg, :name, :linkage

        def initialize(options = {})
          @pkg = options[:pkg]
          @name = options[:name]
          @linkage = options.fetch(:linkage, :static)
        end

        def inspect
          "#<#{self.class} #{pkg}/#{name}>"
        end

        def dynamic?
          @linkage == :dynamic
        end
      end
    end
  end
end
