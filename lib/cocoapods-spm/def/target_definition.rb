require "cocoapods-spm/def/spm_package"

module Pod
  class Podfile
    class TargetDefinition
      def store_spm_pkg(name, options)
        spm_pkgs << SPM::Package.new(name, options)
      end

      def spm_pkgs
        @spm_pkgs ||= []
      end
    end
  end
end
