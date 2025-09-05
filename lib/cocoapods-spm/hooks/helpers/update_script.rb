require "cocoapods-spm/hooks/base"

module Pod
  module SPM
    module UpdateScript
      module Mixin
        def update_script(options = {})
          script_name = options[:name]
          content_by_target = options[:content_by_target]
          targets = aggregate_targets + pod_targets.flat_map do |t|
            t.test_specs.map { |s| Target::NonLibrary.new(underlying: t, spec: s) }
          end

          targets.each do |target|
            lines, input_paths, output_paths = content_by_target.call(target)
            next if input_paths.empty?

            update_script_content(
              path: target.send("#{script_name}_path"),
              before: options[:insert_before],
              insert: lines.join("\n")
            )

            # Update input/output files
            user_build_configurations.each_key do |config|
              append_contents = lambda do |method_name, contents|
                target.send(method_name, config).open("r+") do |f|
                  existing = f.readlines(chomp: true)
                  contents.each { |p| f << "\n" << p unless existing.include?(p) }
                end
              end
              append_contents.call("#{script_name}_input_files_path", input_paths)
              append_contents.call("#{script_name}_output_files_path", output_paths)
            end
          end
        end

        private

        def update_script_content(options = {})
          match_content = options[:before]
          insert_content = <<~SH
            # --------------------------------------------------------
            # Added by `cocoapods-spm`
            # --------------------------------------------------------
            #{options[:insert]}
            # --------------------------------------------------------
          SH
          options[:path].open("r+") do |f|
            content = f.read
            offset = content.index(match_content) unless match_content.nil?
            if offset.nil?
              f << "\n" << insert_content
            else
              f.seek(offset)
              after_content = f.read
              f.seek(offset)
              f << "\n" << insert_content << after_content
            end
          end
        end
      end
    end
  end
end
