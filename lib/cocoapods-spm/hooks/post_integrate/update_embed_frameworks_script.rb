require "cocoapods-spm/hooks/base"

module Pod
  module SPM
    class Hook
      class UpdateEmbedFrameworksScript < Hook
        def run
          aggregate_targets.each do |target|
            update_embed_frameworks_script(target)
            user_build_configurations.each_key do |config|
              update_embed_frameworks_script_input_files_path(target, config)
            end
          end
        end

        private

        def update_embed_frameworks_script(target)
          target.embed_frameworks_script_path.open("a") do |f|
            f << "\n" << <<~SH
              # --------------------------------------------------------
              # Added by `cocoapods-spm` to embed SPM package frameworks
              # --------------------------------------------------------
              if [[ -d "${BUILT_PRODUCTS_DIR}/PackageFrameworks" ]]; then
                for framework_path in "${BUILT_PRODUCTS_DIR}/PackageFrameworks/"*.framework; do
                  install_framework "${framework_path}"
                done
              fi
              # --------------------------------------------------------
            SH
          end
        end

        def update_embed_frameworks_script_input_files_path(target, config)
          target.embed_frameworks_script_input_files_path(config).open("a") do |f|
            f << "\n" << "${BUILT_PRODUCTS_DIR}/PackgeFrameworks"
          end
        end
      end
    end
  end
end
