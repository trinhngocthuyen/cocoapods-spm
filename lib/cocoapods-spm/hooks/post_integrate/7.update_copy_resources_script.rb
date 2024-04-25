require "cocoapods-spm/hooks/base"
require "cocoapods-spm/hooks/helpers/update_script"

module Pod
  module SPM
    class Hook
      class UpdateCopyResourcesScript < Hook
        include UpdateScript::Mixin

        def run
          aggregate_targets.each do |target|
            next if resource_paths_for(target).empty?

            update_copy_resources_script(target)
            user_build_configurations.each_key do |config|
              update_copy_resources_script_files_path(target, config)
            end
          end
        end

        private

        def resource_paths_for(target)
          @spm_resolver.result.spm_targets_for(target).flat_map(&:resources).map(&:built_resource_path).uniq
        end

        def update_copy_resources_script(target)
          lines = resource_paths_for(target).map { |p| "install_resource \"#{p}\"" }
          update_script(
            path: target.copy_resources_script_path,
            before: Generator::CopyResourcesScript::RSYNC_CALL,
            insert: lines.join("\n")
          )
        end

        def update_copy_resources_script_files_path(target, config)
          input_paths = resource_paths_for(target)
          output_paths = input_paths.map do |p|
            "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/#{File.basename(p)}"
          end
          target.copy_resources_script_input_files_path(config).open("a") do |f|
            input_paths.each { |p| f << "\n" << p }
          end
          target.copy_resources_script_output_files_path(config).open("a") do |f|
            output_paths.each { |p| f << "\n" << p }
          end
        end
      end
    end
  end
end
