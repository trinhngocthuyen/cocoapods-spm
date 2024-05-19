module Pod
  module IOUtils
    def self.symlink(src, dst)
      src = Pathname.new(src) unless src.is_a?(Pathname)
      dst = Pathname.new(dst) unless dst.is_a?(Pathname)
      dst.delete if dst.exist?
      File.symlink(src.absolute? ? src : src.realpath, dst)
    end
  end
end
