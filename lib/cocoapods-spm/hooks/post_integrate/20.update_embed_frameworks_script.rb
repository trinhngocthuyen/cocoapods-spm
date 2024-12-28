require "cocoapods-spm/hooks/base"
require "cocoapods-spm/hooks/helpers/update_script"

module Pod
  module SPM
    class Hook
      class UpdateEmbedFrameworksScript < Hook
        include UpdateScript::Mixin

        def run
          update_script(
            name: :embed_frameworks_script,
            content_by_target: lambda do |target|
              input_paths = framework_paths_for(target)
              output_paths = input_paths.map do |p|
                "${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}/#{File.basename(p)}"
              end
              lines = input_paths.map { |p| "install_framework \"#{p}\"" }
              [lines, input_paths, output_paths]
            end
          )
        end

        private

        def framework_paths_for(target)
          @spm_resolver.result.spm_targets_for(target).select(&:dynamic?).map(&:built_framework_path).uniq
        end
      end
    end
  end
end
