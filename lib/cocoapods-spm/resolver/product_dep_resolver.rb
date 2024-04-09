module Pod
  module SPM
    class Resolver
      class ProductDependencyResolver
        def initialize(podfile, result)
          @podfile = podfile
          @result = result
        end

        def resolve
          # To be implemented
        end
      end
    end
  end
end
