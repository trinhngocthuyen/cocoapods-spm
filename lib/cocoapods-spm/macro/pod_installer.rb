require "cocoapods-spm/dsl/spec"
require "cocoapods-spm/macro/fetcher"
require "cocoapods-spm/macro/prebuilder"

module Pod
  class Installer
    class MacroPodInstaller < PodSourceInstaller
      include SPM::Config::Mixin

      def install!
        install_macro_pod!
        super
      end

      private

      def fetcher
        @fetcher ||= SPM::MacroFetcher.new(
          name: name,
          specs_by_platform: specs_by_platform,
          can_cache: can_cache?
        )
      end

      def prebuilder
        @prebuilder ||= SPM::MacroPrebuilder.new(name: name)
      end

      def install_macro_pod!
        fetcher.run
        prebuilder.run
      end
    end
  end
end
