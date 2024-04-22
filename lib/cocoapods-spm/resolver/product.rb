module Pod
  module SPM
    class Resolver
      class Product
        attr_reader :pkg, :name, :linkage, :headers_path

        def initialize(options = {})
          @pkg = options[:pkg]
          @name = options[:name]
          @linkage = options.fetch(:linkage, :static)
          @headers_path = options[:headers_path]
          @binary_basename = options[:binary_basename]
        end

        def inspect
          "#<#{self.class} #{pkg}/#{name}>"
        end

        def binary?
          !@binary_basename.nil?
        end

        def dynamic?
          @linkage == :dynamic
        end

        def linker_flags
          return ["-framework \"#{name}\""] if dynamic?
          return ["-l\"#{name}.o\""] unless binary?

          case @binary_basename
          when /(\S+)\.framework/ then ["-framework \"#{$1}\""]
          when /lib(\S+)\.a/ then ["-library \"#{$1}\""]
          when /(\S+\.a)/ then ["\"${PODS_CONFIGURATION_BUILD_DIR}/#{$1}\""]
          end
        end
      end
    end
  end
end
