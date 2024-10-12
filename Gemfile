source "https://rubygems.org"

gemspec

CP_VERSION = "1.15.2".freeze

def use_local_cocoapods?
  ENV.fetch("COCOAPODS_LOCAL", "true") == "true"
end

def ensure_local_gem(name, url, version)
  local_repo_dir = ".local/#{name}"
  local_repo_absolute_dir = "#{__dir__}/#{local_repo_dir}"
  return unless use_local_cocoapods?
  return if Dir.exist?(local_repo_absolute_dir)

  puts "\033[1;32m>>> Cloning #{name} (#{version}) from #{url} to #{local_repo_dir} for development...\033[0m"
  system("git clone --branch #{version} --depth=1 #{url} #{local_repo_absolute_dir}")
end

ensure_local_gem "cocoapods", "https://github.com/CocoaPods/CocoaPods.git", CP_VERSION
ensure_local_gem "cocoapods-core", "https://github.com/CocoaPods/Core.git", CP_VERSION

group :development do
  if use_local_cocoapods?
    gem "cocoapods", :path => ".local/cocoapods"
    gem "cocoapods-core", :path => ".local/cocoapods-core"
  else
    gem "cocoapods", CP_VERSION
  end
  gem "bundler", "> 1.3"
  gem "cocoapods-compact-spec"
  gem "cocoapods-xcconfig-hooks"
  gem "pry-nav"
  gem "rspec"
  gem "rubocop"
end
