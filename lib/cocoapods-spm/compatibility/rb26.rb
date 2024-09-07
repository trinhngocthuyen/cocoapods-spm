module Enumerable
  unless method_defined?(:filter_map)
    def filter_map
      return enum_for(:filter_map) unless block_given?

      result = []
      each do |element|
        value = yield(element)
        result << value if value
      end
      result
    end
  end
end
