require "cocoapods-spm/config"

module Pod
  class Podfile
    attr_accessor :spm_resolver

    alias origin_pod pod
    def config_cocoapods_spm(options)
      SPM::Config.instance.dsl_config = options
    end

    def macro_pods
      @macro_pods ||= {}
    end

    def pod(name = nil, *requirements)
      macro = requirements[0].delete(:macro) if requirements.first.is_a?(Hash)
      macro ||= {}
      unless macro.empty?
        requirements[0][:path] = prepare_macro_pod_dir(name, macro)
        macro_pods[name] = macro
      end
      origin_pod(name, *requirements)
    end

    def spm_pkg(name, options)
      current_target_definition.store_spm_pkg(name, options)
    end

    def spm_pkgs_for(target)
      spm_pkgs_by_aggregate_target[target.to_s]
    end

    def spm_pkgs_by_aggregate_target
      @spm_pkgs_by_aggregate_target ||= begin
        common_spm_pkgs = root_target_definitions.flat_map(&:spm_pkgs)
        target_definition_list.reject(&:abstract?).to_h do |target|
          [target.to_s, (common_spm_pkgs + target.spm_pkgs).uniq(&:name)]
        end
      end
    end

    private

    def prepare_macro_pod_dir(name, requirement)
      link = requirement[:git]
      podspec_content = <<~HEREDOC
        Pod::Spec.new do |s|
          s.name = "#{name}"
          s.version = "0.0.1"
          s.summary = "#{name}"
          s.description = "#{name}"
          s.homepage = "#{link}"
          s.license = "MIT"
          s.authors = "dummy@gmail.com"
          s.source = #{requirement}
          s.source_files = "Sources/**/*"
        end
      HEREDOC

      path = Pathname(".spm.pods/#{name}")
      (path / ".prebuilt").mkpath
      (path / "Sources").mkpath
      (path / "#{name}.podspec").write(podspec_content)
      path
    end
  end
end
