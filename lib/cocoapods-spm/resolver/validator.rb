module Pod
  module SPM
    class Validator
      def initialize(aggregate_targets, result)
        @aggregate_targets = aggregate_targets
        @spm_pkgs = result.spm_pkgs
        @project_pkgs = result.project_pkgs
        @spm_dependencies_by_target = result.spm_dependencies_by_target
      end

      def validate!
        verify_no_missing_pkgs
        verify_products_exist
      end

      private

      def verify_products_exist
        @spm_dependencies_by_target.values.flatten.uniq.each do |d|
          next if @project_pkgs.pkg_desc_of(d.pkg.name).products.any? { |p| p.name == d.product }

          raise Informative, <<~DESC
            There was an invalid dependency in Podfile or podspecs.
            Package `#{d.pkg.name}` does not contain product `#{d.product}`
          DESC
        end
      end

      def dependents_of_pkg(name)
        @specs ||= @aggregate_targets.flat_map(&:specs).uniq
        @specs.select { |s| s.spm_dependencies.any? { |d| d.name == name } }.map(&:name)
      end

      def verify_no_missing_pkgs
        missing_pkgs = @spm_dependencies_by_target.values.flatten.select { |d| d.pkg.nil? }.map(&:name).uniq
        return if missing_pkgs.empty?

        messages = ["The following packages were not declared in Podfile:"]
        messages += missing_pkgs.map { |pkg| "  • #{pkg}: used by #{dependents_of_pkg(pkg).join(', ')}" }
        messages << "Use the `spm_pkg` method to declare those packages in Podfile."
        raise Informative, messages.join("\n")
      end
    end
  end
end
