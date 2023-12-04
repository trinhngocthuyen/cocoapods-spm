# cocoapods-spm

[![License](https://img.shields.io/badge/license-MIT-green.svg?style=flat&color=blue)](https://github.com/trinhngocthuyen/cocoapods-spm/blob/main/LICENSE.txt)
[![Gem](https://img.shields.io/gem/v/cocoapods-spm.svg?style=flat&color=blue)](https://rubygems.org/gems/cocoapods-spm)

A CocoaPods plugin to add SPM dependencies to CocoaPods targets.

## Installation

    $ gem install cocoapods-spm

## Usage

### Declaring dependencies in podspecs

Use method `spm_dependency` to declare SPM dependencies to a podspec.

```rb
Pod::Spec.new do |s|
  s.name = "Foo"

  s.spm_dependency(
    url: "https://github.com/trinhngocthuyen/orcam.git",
    requirement: {
      kind: "branch",
      branch: "main",
    },
    products: ["Orcam"]
  )
end
```

