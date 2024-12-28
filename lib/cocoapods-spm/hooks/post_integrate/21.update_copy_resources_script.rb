require "cocoapods-spm/hooks/base"
require "cocoapods-spm/hooks/helpers/update_script"

module Pod
  module SPM
    class Hook
      class UpdateCopyResourcesScript < Hook
        include UpdateScript::Mixin

        def run
          update_script(
            name: :copy_resources_script,
            insert_before: Generator::CopyResourcesScript::RSYNC_CALL,
            content_by_target: lambda do |target|
              input_paths = resource_paths_for(target)
              output_paths = input_paths.map do |p|
                "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/#{File.basename(p)}"
              end
              lines = input_paths.map { |p| "install_resource \"#{p}\"" }
              [lines, input_paths, output_paths]
            end
          )
        end

        private

        def resource_paths_for(target)
          @spm_resolver.result.spm_targets_for(target).flat_map(&:resources).map(&:built_resource_path).uniq
        end
      end
    end
  end
end
