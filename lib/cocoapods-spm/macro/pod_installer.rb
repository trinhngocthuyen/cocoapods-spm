require_relative "../specification"
require_relative "fetcher"
require_relative "prebuilder"

module Pod
  class Installer
    class MacroPodInstaller < PodSourceInstaller
      include Pod::SPM::Config::Mixin

      def install!
        install_macro_pod!
        super
      end

      private

      def fetcher
        @fetcher ||= Pod::SPM::MacroFetcher.new(
          name: name,
          specs_by_platform: specs_by_platform,
          can_cache: can_cache?
        )
      end

      def prebuilder
        @prebuilder ||= Pod::SPM::MacroPrebuilder.new(name: name)
      end

      def install_macro_pod!
        fetcher.run
        prebuilder.run
      end
    end
  end
end
