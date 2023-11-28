require "cocoapods-spm/main"

Pod::HooksManager.register("cocoapods-spm", :post_install) do |context|
  Pod::SPM::Hook.new(context).run
end
