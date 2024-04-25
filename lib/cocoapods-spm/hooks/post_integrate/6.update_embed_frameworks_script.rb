require "cocoapods-spm/hooks/base"
require "cocoapods-spm/hooks/helpers/update_script"

module Pod
  module SPM
    class Hook
      class UpdateEmbedFrameworksScript < Hook
        include UpdateScript::Mixin

        def run
          aggregate_targets.each do |target|
            next if framework_paths_for(target).empty?

            update_embed_frameworks_script(target)
            user_build_configurations.each_key do |config|
              update_embed_frameworks_script_files_path(target, config)
            end
          end
        end

        private

        def framework_paths_for(target)
          @spm_resolver.result.spm_targets_for(target).select(&:dynamic?).map(&:built_framework_path).uniq
        end

        def update_embed_frameworks_script(target)
          lines = framework_paths_for(target).map { |p| "install_framework \"#{p}\"" }
          update_script(
            path: target.embed_frameworks_script_path,
            insert: lines.join("\n")
          )
        end

        def update_embed_frameworks_script_files_path(target, config)
          input_paths = framework_paths_for(target)
          output_paths = input_paths.map do |p|
            "${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}/#{File.basename(p)}"
          end
          target.embed_frameworks_script_input_files_path(config).open("a") do |f|
            input_paths.each { |p| f << "\n" << p }
          end
          target.embed_frameworks_script_output_files_path(config).open("a") do |f|
            output_paths.each { |p| f << "\n" << p }
          end
        end
      end
    end
  end
end
