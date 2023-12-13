require "cocoapods-spm/hooks/base"
require "cocoapods-spm/macro/settings_updater" # TODO: Merge to this file

module Pod
  module SPM
    class Hook
      class UpdateMacroSettings < Hook
        def run
          MacroSettingsUpdater.new(
            pod_targets: @analysis_result.pod_targets,
            aggregate_targets: @analysis_result.targets
          )
        end
      end
    end
  end
end
