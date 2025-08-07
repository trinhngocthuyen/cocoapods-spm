Pod::CompactSpec.new do |s|
  s.name = "Services"
  s.dependency "Logger"
  s.spm_dependency "SwiftyBeaver/SwiftyBeaver"

  s.test_spec do |ss|
    ss.source_files = "Tests/**.swift"
    ss.spm_dependency "DebugKit/DebugKit"
    ss.spm_dependency "CoreUtils/TestKit"
  end
end
