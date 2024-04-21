# cocoapods-spm (CocoaPods + SPM)

[![Test](https://github.com/trinhngocthuyen/cocoapods-spm/actions/workflows/test.yml/badge.svg)](https://img.shields.io/github/workflow/status/trinhngocthuyen/cocoapods-spm/test)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](https://github.com/trinhngocthuyen/cocoapods-spm/blob/main/LICENSE.txt)
[![Gem](https://img.shields.io/gem/v/cocoapods-spm.svg)](https://rubygems.org/gems/cocoapods-spm)

A CocoaPods plugin to add SPM dependencies to CocoaPods-based projects.

## Installation

Via [Bundler](https://bundler.io): Add the gem `cocoapods-spm` to the Gemfile of your project.

```rb
gem "cocoapods-spm"
```

Via [RubyGems](https://rubygems.org):
```sh
$ gem install cocoapods-spm
```

## Usage

Check out the demo at: [examples](/examples).

### Declaring SPM packages

#### In a podspec

In the podspec of a pod, use `spm_dependency` to specify the SPM package that the pod depends on, in the following format:
```rb
s.spm_dependency "<package-name>/<ProductName>"
```
For example, if a pod depends on the `Orcam` library of this [Orcam package](https://github.com/trinhngocthuyen/orcam), you just need to declare the depenency in the podspec as follows:

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
spm_pkg "Orcam", :url => "https://github.com/trinhngocthuyen/orcam.git", :branch => "main"
```

### Using Swift Macros with cocoapods-spm

There are two approaches when integrating a Swift macro to a project.

First, you can integrate the macro package just like any other SPM package, by declaring it in Podfile using the `spm_pkg` method, instructed in the [previous section](#declaring-spm-packages).

Another way is to integrate a macro to the project as prebuilt binary. This was inspired by the approach mentioned in [this blog post](https://www.polpiella.dev/binary-swift-macros). This approach helps reduce some build time. This is really beneficial because:
- It takes time to build such a macro package. [swift-syntax](https://github.com/apple/swift-syntax), one of its dependencies, already takes up 10-15s.
- A macro is usually used by many dependants. This leads to delays in compiling those dependants.

By integrating macros as prebuilt binaries, the additional build time should be insignificant.

#### Integrating macros as prebuilt binaries

In Podfile, simply use the `:macro` option when declaring a pod.

```rb
pod "MacroCodableKit", :macro => {
  :git => "https://github.com/mikhailmaslo/macro-codable-kit",
  :tag => "0.3.0"
}
```

When running pod install, the plugin prebuilds the declared macros (if not prebuilt before) from their sources.

Wanna know more about its under-the-hood? Check out [this doc](/docs/under-the-hood-swift-binary-macros.md).

Alternatively, you can prebuild macros with the CLI. Check the [subsequent section](#using-the-cli) for details.

### Using the CLI

This plugin offers some CLI usages under the `spm` subcommand (`bundle exec pod spm`). To explore the usages, run the command with the `--help` option.

As follows are some common usages.

**Fetching macro sources**

```sh
bundle exec pod spm fetch --all
```
The downloaded sources are put in the `.spm.pods/.downloaded` folder.

**Prebuilding macros**

```sh
# Prebuild all macros
bundle exec pod spm prebuild --all

# Prebuild some macros with the given config
bundle exec pod spm prebuild --macros=Orcam --config=debug
```

## Contribution

Refer to the [contributing guidelines](/CONTRIBUTING.md) for details.

## License

The plugin is available as open-source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
