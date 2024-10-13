require "cocoapods-spm/config"
require "cocoapods-spm/helpers/patch"

module Pod
  class Podfile
    include Mixin::PatchingBehavior
    attr_accessor :spm_resolver

    def config_cocoapods_spm(options)
      SPM::Config.instance.dsl_config = options
    end

    def macro_pods
      @macro_pods ||= {}
    end

    patch_method :pod do |name = nil, *requirements|
      macro = requirements[0].delete(:macro) if requirements.first.is_a?(Hash)
      macro ||= {}
      unless macro.empty?
        requirements[0][:path] = prepare_macro_pod_dir(name, macro).to_s
        macro_pods[name] = macro
      end
      origin_pod(name, *requirements)
    end

    def spm_pkg(name, options)
      current_target_definition.store_spm_pkg(name, options)
    end

    def spm_pkgs
      spm_pkgs_by_aggregate_target.values.flatten.uniq(&:name)
    end

    def spm_pkgs_for(target)
      spm_pkgs_by_aggregate_target[target.to_s]
    end

    def spm_pkgs_by_aggregate_target
      @spm_pkgs_by_aggregate_target ||= begin
        dict = {}
        to_visit = root_target_definitions.map { |t| [t, []] }
        until to_visit.empty?
          target, acc = to_visit.pop
          dict[target.to_s] = (target.spm_pkgs + acc).uniq
          to_visit += target.children.map { |t| [t, dict[target.to_s]] }
        end
        dict
      end
    end

    def platforms
      @platforms ||= target_definition_list.filter_map { |d| d.platform&.name }.uniq || [:ios]
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

      path = Pod::SPM::Config.instance.macro_root_dir / name
      (path / "Sources").mkpath
      (path / "#{name}.podspec").write(podspec_content)
      path
    end
  end
end
