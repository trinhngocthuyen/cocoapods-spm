require "json"

module Pod
  module SPM
    class Metadata
      attr_reader :raw

      def initialize(raw)
        @raw = raw
      end

      def self.from_s(str)
        new(JSON.parse(str))
      end

      def self.from_file(path)
        from_s(File.read(path))
      end

      def self.for_pod(name)
        from_file(Config.instance.macro_root_dir / name / "metadata.json")
      end

      def [](key)
        raw[key]
      end

      def targets
        raw["targets"]
      end

      def products
        raw["products"]
      end

      def product_names_of_target(name)
        names = products.select { |h| h["targets"].include?(name) }.map { |h| h["name"] }
        names.empty? ? [name] : names
      end

      def targets_of_type(type)
        targets.select { |t| t["type"] == type }
      end

      def macro_impl_name
        targets_of_type("macro").first&.fetch("name")
      end
    end
  end
end
