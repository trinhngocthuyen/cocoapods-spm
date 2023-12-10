# cocoapods-spm

[![License](https://img.shields.io/badge/license-MIT-green.svg?style=flat&color=blue)](https://github.com/trinhngocthuyen/cocoapods-spm/blob/main/LICENSE.txt)
[![Gem](https://img.shields.io/gem/v/cocoapods-spm.svg?style=flat&color=blue)](https://rubygems.org/gems/cocoapods-spm)

A CocoaPods plugin to add SPM dependencies to CocoaPods targets.

## Installation

    $ gem install cocoapods-spm

## Usage

### Declaring SPM packages

#### In a podspec

In the podspec of a pod, use `spm_dependency` to specify the SPM package that the pod depends on, in the following format:
```rb
s.spm_dependency "<package-name>/<ProductName>"
```
For example, if a pod depends on the `Orcam` library of this package https://github.com/trinhngocthuyen/orcam, we declare this depenency in the podspec as follows:

```rb
Pod::Spec.new do |s|
  s.name = "Foo"
  s.spm_dependency "Orcam/Orcam" # <--- HERE
end
```

NOTE: Like pod dependencies, the SPM depenency in a podspec should not state its source. Rather, the source of an SPM package (ex. its repo, which branch, commit...) should be declared in Podfile.

#### In Podfile

The `spm_pkg` method to declare the package being used. This method's usage is pretty much similar to the `pod` method.

```rb
spm_pkg "Orcam", :git => "https://github.com/trinhngocthuyen/orcam.git", :branch => "main"
```

### Using Swift Macros with cocoapods-spm

TBU
