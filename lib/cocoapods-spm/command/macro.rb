require "cocoapods-spm/command/macro/fetch"
require "cocoapods-spm/command/macro/prebuild"
require "cocoapods-spm/command/macro/deprecated"

module Pod
  class Command
    class Spm < Command
      class Macro < Spm
        self.summary = "Working with macros"
        self.abstract_command = true
      end
    end
  end
end
