require "cocoapods-spm/config"
require "cocoapods-spm/def/spm_dependency"

module Pod
  class Specification
    def spm_dependencies
      @spm_dependencies ||= []
    end

    def spm_dependency(name, options = {})
      spm_dependencies << SPM::Dependency.new(name, options)
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
