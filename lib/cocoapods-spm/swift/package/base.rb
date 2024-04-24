require "json"

module Pod
  module Swift
    class PackageDescriptionBaseObject
      attr_reader :raw, :parent

      def initialize(raw, parent: nil)
        @raw = raw
        @parent = parent
      end

      def root
        @root ||= begin
          node = self
          node = node.parent until node.parent.nil?
          node
        end
      end

      def pkg_name
        root.name
      end

      def self.from_s(str)
        new(JSON.parse(str))
      end

      def self.from_file(path)
        from_s(File.read(path))
      end

      def inspect
        "#<#{self.class} #{name}>"
      end

      alias to_s inspect

      def [](key)
        raw[key]
      end

      def name
        raw["name"]
      end

      def dup_with_attrs(options = {})
        copy = dup
        options.each { |key, value| copy.instance_variable_set("@#{key}", value) }
        copy
      end
    end
  end
end
