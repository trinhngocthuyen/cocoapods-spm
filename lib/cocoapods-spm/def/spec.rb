require "cocoapods-spm/config"

module Pod
  class Specification
    def spm_dependencies
      @spm_dependencies ||= {}
    end

    def spm_dependency(dependency)
      cmps = dependency.split("/")
      raise "SPM dependency must be declared as follows: `s.spm_dependency '<Package>/<Product>'`" if cmps.count != 2

      pkg, product = cmps
      spm_dependencies[pkg] ||= []
      spm_dependencies[pkg] << product
    end

    def with
      spec = Pod::Spec.new(
        parent,
        name,
        test_specification,
        app_specification: app_specification
      )
      spec.attributes_hash = attributes_hash.dup
      yield spec if block_given?
      spec
    end
  end
end
