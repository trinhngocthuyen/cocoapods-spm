module Pod
  class Target
    class NonLibrary
      attr_reader :underlying, :spec

      def initialize(underlying: nil, spec: nil)
        @underlying = underlying
        @spec = spec
      end

      def name
        if underlying.is_a?(Xcodeproj::Project::Object::PBXNativeTarget) && underlying.test_target_type?
          return underlying.name.sub(/-(Unit|UI)-/, "/")
        end

        spec.name
      end

      def platform
        underlying.platform
      end

      def xcconfig_path(variant)
        # For test spec, return the path as <TargetName>.unit-test.<Config>.xcconfig
        # Here, we're trying to get `unit-tests` out of the spec, then calling
        # `underlying.xcconfig_path("unit-tests.debug")` to get the result
        variant_prefix = underlying.spec_label(spec).sub("#{underlying.name}-", "")
        underlying.xcconfig_path("#{variant_prefix}.#{variant}")
      end
    end
  end
end
