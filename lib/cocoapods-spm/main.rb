require "pry" if ENV["COCOAPODS_IMPORT_PRY"] == "true"
require "cocoapods-spm/compatibility/all"
require "cocoapods-spm/helpers/io"
require "cocoapods-spm/helpers/patch"
require "cocoapods-spm/config"
require "cocoapods-spm/executables"
require "cocoapods-spm/def/installer"
require "cocoapods-spm/def/target_definition"
require "cocoapods-spm/def/podfile"
require "cocoapods-spm/def/spec"
require "cocoapods-spm/def/target"
require "cocoapods-spm/patch/aggregate_target"
require "cocoapods-spm/patch/installer"
require "cocoapods-spm/command/spm"
