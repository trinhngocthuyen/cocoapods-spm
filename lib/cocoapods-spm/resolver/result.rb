module Pod
  module SPM
    class Resolver
      class Result
        class WritableResult < Result
          attr_accessor :spm_pkgs, :spm_dependencies_by_target

          def to_read_only
            Result.new(spm_pkgs: spm_pkgs, spm_dependencies_by_target: spm_dependencies_by_target)
          end
        end

        attr_reader :spm_pkgs, :spm_dependencies_by_target

        def initialize(options = {})
          @spm_pkgs = options[:spm_pkgs] || []
          @spm_dependencies_by_target = options[:spm_dependencies_by_target] || {}
        end

        def spm_dependencies_for(target)
          @spm_dependencies_by_target[target.to_s]
        end
      end
    end
  end
end
