module Pod
  module SPM
    class Resolver
      class Result
        class WritableResult < Result
          attr_accessor :spm_pkgs, :spm_dependencies_by_target, :spm_products, :metadata_cache

          def to_read_only
            Result.new(
              spm_pkgs: spm_pkgs,
              spm_dependencies_by_target: spm_dependencies_by_target,
              spm_products: spm_products,
              metadata_cache: metadata_cache
            )
          end
        end

        attr_reader :spm_pkgs, :spm_dependencies_by_target, :spm_products, :metadata_cache

        def initialize(options = {})
          @spm_pkgs = options[:spm_pkgs] || []
          @spm_dependencies_by_target = options[:spm_dependencies_by_target] || {}
          @spm_products = options[:spm_products] || {}
          @metadata_cache = options[:metadata_cache] || {}
        end

        def spm_dependencies_for(target)
          @spm_dependencies_by_target[target.to_s]
        end

        def spm_products_for(target)
          spm_dependencies_for(target).flat_map { |d| @spm_products[d.product] }.uniq(&:name)
        end
      end
    end
  end
end
