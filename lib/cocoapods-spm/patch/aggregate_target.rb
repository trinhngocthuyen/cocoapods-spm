require "cocoapods-spm/helpers/patch"

module Pod
  class AggregateTarget
    include Mixin::PatchingBehavior

    private

    patch_method :includes_frameworks? do
      origin_includes_frameworks? || includes_dynamic_spm_dependencies?
    end

    patch_method :includes_resources? do
      origin_includes_resources? || includes_spm_resouces?
    end

    def includes_dynamic_spm_dependencies?
      podfile.spm_resolver.result.spm_targets_for(self).any?(&:dynamic?)
    end

    def includes_spm_resouces?
      !podfile.spm_resolver.result.spm_targets_for(self).all? { |t| t.resources.empty? }
    end
  end
end
