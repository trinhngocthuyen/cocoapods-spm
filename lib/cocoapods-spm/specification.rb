module Pod
  class Specification
    attr_reader :spm_dependencies

    def spm_dependency(options)
      @spm_dependencies ||= []
      @spm_dependencies << options
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
