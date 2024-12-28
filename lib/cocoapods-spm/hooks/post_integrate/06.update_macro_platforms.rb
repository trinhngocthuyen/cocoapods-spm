require "cocoapods-spm/hooks/base"
require "cocoapods-spm/macro/metadata"

module Pod
  module SPM
    class Hook
      class UpdateMacroPlatforms < Hook
        def run
          to_save = Set.new
          native_targets.each do |target|
            name = pod_name_of_target(target.name)
            metadata = macro_metadata_for_pod(name)
            next if metadata.nil?

            settings = metadata.platform_build_settings
            target.build_configurations.each do |config|
              settings.each { |k, v| config.build_settings[k] = v }
            end
            to_save << target.project
          end
          to_save.each(&:save)
        end
      end
    end
  end
end
