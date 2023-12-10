Dir["#{__dir__}/*.rb"].sort.each { |f| require f }

module Pod
  module SPM
    class Hook
      class All < self
        def run
          Dir["#{__dir__}/*.rb"]
            .map { |f| File.basename(f, ".*") }
            .reject { |id| ["all", "base"].include?(id) }
            .each do |id|
              cls_name = "Pod::SPM::#{id.camelize}Hook"
              UI.message "Running hook: #{cls_name}"
              cls_name.constantize.new(@context).run
            end
        end
      end
    end
  end
end
