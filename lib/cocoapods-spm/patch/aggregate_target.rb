module Pod
  class AggregateTarget
    alias origin_includes_frameworks? includes_frameworks?

    def includes_frameworks?
      origin_includes_frameworks? || includes_dynamic_spm_dependencies?
    end

    def includes_dynamic_spm_dependencies?
      podfile.spm_analyzer.spm_dependencies_for(self).any?(&:dynamic)
    end
  end
end
