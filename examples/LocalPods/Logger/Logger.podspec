Pod::CompactSpec.new do |s|
  s.platforms = { :ios => "16.0", :osx => "14.0" }
  s.name = "Logger"
  s.spm_dependency "SwiftyBeaver/SwiftyBeaver"
end
