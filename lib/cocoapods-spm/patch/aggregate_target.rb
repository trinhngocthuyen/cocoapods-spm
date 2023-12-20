module Pod
  class AggregateTarget
    alias origin_includes_frameworks? includes_frameworks?

    def includes_frameworks?
      origin_includes_frameworks? || !podfile.spm_pkgs_for(self).empty?
    end
  end
end
