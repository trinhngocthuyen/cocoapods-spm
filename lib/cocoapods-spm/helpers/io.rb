module Pod
  module IOUtils
    def self.symlink(src, dst)
      # NOTE: File operations are case-insensitive (foo.json and Foo.json are identical)
      return if File.identical?(src, dst)

      src = Pathname.new(src) unless src.is_a?(Pathname)
      dst = Pathname.new(dst) unless dst.is_a?(Pathname)
      dst.dirname.mkpath unless dst.dirname.exist?
      dst.delete if dst.exist?
      File.symlink(src.absolute? ? src : src.realpath, dst)
    end
  end
end
