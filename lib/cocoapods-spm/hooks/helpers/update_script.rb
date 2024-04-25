require "cocoapods-spm/hooks/base"

module Pod
  module SPM
    module UpdateScript
      module Mixin
        def update_script(options = {})
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
