require "cocoapods-spm/hooks/base"
require "cocoapods-spm/macro/metadata"

module Pod
  module SPM
    class Hook
      class UpdateSettings < Hook
        def run
          update_macro_plugin_flags
          update_packages_flags
        end

        private

        def macro_plugin_flag_by_config
          path_prefix = "${PODS_ROOT}/../#{spm_config.macro_prebuilt_root_dir}"
          @macro_plugin_flag_by_config ||= begin
            hash = user_build_configurations.keys.to_h do |config|
              flags = macro_pods.keys.map do |name|
                metadata = macro_metadata_for_pod(name)
                impl_module_name = metadata.macro_impl_name
                plugin_executable_path =
                  "#{path_prefix}/#{name}/" \
                  "#{impl_module_name}-#{config.to_s.downcase}##{impl_module_name}"
                "-load-plugin-executable \"#{plugin_executable_path}\""
              end.join(" ")
              [config, flags]
            end
            user_build_configurations.each { |config, symbol| hash[symbol] = hash[config] }
            hash
          end
        end

        def update_macro_plugin_flags
          return if spm_config.all_macros.empty?

          perform_settings_update(
            update_targets: lambda do |_, _, config|
              { "OTHER_SWIFT_FLAGS" => macro_plugin_flag_by_config[config] }
            end
          )
        end

        def update_packages_flags
          return if @spm_resolver.result.spm_pkgs.empty?

          perform_settings_update(
            update_targets: lambda do |target, _, _|
              {
                "SOURCE_PACKAGES_CHECKOUTS_DIR" => "${BUILD_ROOT}/../../SourcePackages/checkouts",
                "FRAMEWORK_SEARCH_PATHS" => "\"${PODS_CONFIGURATION_BUILD_DIR}/PackageFrameworks\"",
                "LIBRARY_SEARCH_PATHS" => "\"${PODS_CONFIGURATION_BUILD_DIR}\"",
                "SWIFT_INCLUDE_PATHS" => "$(PODS_CONFIGURATION_BUILD_DIR)",
                "OTHER_SWIFT_FLAGS" => modulemap_args_for_target(target, prefix: "-Xcc"),
                "OTHER_CFLAGS" => modulemap_args_for_target(target),
                "HEADER_SEARCH_PATHS" => header_search_paths_for(target),
                "OTHER_LDFLAGS" => linker_flags_for(target),
              }
            end
          )
        end

        def linker_flags_for(target)
          return [] if !target.is_a?(Pod::AggregateTarget) && target.build_as_static?

          @spm_resolver.result.linker_flags_for(target)
        end

        def modulemap_args_for_target(target, prefix: nil)
          @spm_resolver
            .result
            .spm_targets_for(target)
            .filter_map(&:clang_modulemap_arg)
            .map { |v| prefix.nil? ? v : "#{prefix} #{v}" }
            .join(" ")
        end

        def header_search_paths_for(target)
          @spm_resolver
            .result
            .spm_targets_for(target)
            .filter_map(&:header_search_path_arg)
            .join(" ")
        end
      end
    end
  end
end
