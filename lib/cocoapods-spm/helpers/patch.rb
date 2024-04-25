module Mixin
  module PatchingBehavior
    def patch_method(method_name, &block)
      raw_method_name = "origin_#{method_name}"
      alias_method raw_method_name, method_name
      define_method(method_name, &block)
      private raw_method_name
    end

    def self.included(base)
      base.extend(self)
    end
  end
end
