require "cocoapods-spm/hooks/base"
require "cocoapods-spm/metadata"

module Pod
  module SPM
    class Hook
      class UpdateLinkerFlags < Hook
        def run
          update_linker_flags
        end

        private

        def update_linker_flags
          perform_settings_update(
            update_aggregate_targets: lambda do |target, _, _|
              spm_deps = @spm_analyzer.spm_dependencies_by_target[target.to_s].to_a
              flags = spm_deps.map { |d| "-l\"#{d.product}.o\"" }
              { "OTHER_LDFLAGS" => flags }
            end
          )
        end
      end
    end
  end
end
