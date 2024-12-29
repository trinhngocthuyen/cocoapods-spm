module Pod
  module SPM
    module PathMixn
      def prepare_dir(dir)
        dir.mkpath
        dir
      end
    end
  end
end
