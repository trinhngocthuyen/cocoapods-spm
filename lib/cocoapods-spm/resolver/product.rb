module Pod
  module SPM
    class Resolver
      class Product
        attr_reader :pkg, :name, :linkage, :headers_path, :binary

        alias binary? binary

        def initialize(options = {})
          @pkg = options[:pkg]
          @name = options[:name]
          @linkage = options.fetch(:linkage, :static)
          @headers_path = options[:headers_path]
          @binary = options[:binary]
        end

        def inspect
          "#<#{self.class} #{pkg}/#{name}>"
        end

        def dynamic?
          @linkage == :dynamic
        end

        def linked_as_framework?
          dynamic? || binary?
        end
      end
    end
  end
end
