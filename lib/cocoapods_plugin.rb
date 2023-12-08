require_relative "cocoapods-spm/main"

Pod::HooksManager.register("cocoapods-spm", :post_install) do |context|
  Pod::SPM::Hook::All.new(context).run
end
