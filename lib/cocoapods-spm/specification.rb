module Pod
  class Specification
    attr_reader :spm_dependencies

    def spm_dependency(options)
      @spm_dependencies ||= []
      @spm_dependencies << options
    end
  end
end
