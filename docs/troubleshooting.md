[< Documentation](README.md)

# Troubleshooting

## Linking strategy

Typically, this plugin offers two ways of handling linking libraries/frameworks of a package.
- Based on xcconfig settings
- Xcode's default linking

### Based on xcconfig settings

We rely on xcconfig settings to provide all linker flags for a package's libraries/frameworks. This aligns with how CocoaPods is currently linking pod targets. This strategy is going to be how the plugin handles linking in the long term.

⚠️ DISCLAIMER: Because the plugin is still in active development, this way of linking may not work in some corner cases, especially with C++/Objective-C libraries/frameworks. You may try the Xcode's default linking in the following section as a workaround. And please submit a bug report if you encounter such an issue.

### Xcode's default linking

With this strategy, a product of a package is added to the *"Link Binary With Libraries"* section of a dependent target.

![](/docs/res/xcode_default_linking.jpg)

To opt in for this strategy, use the option `use_default_xcode_linking` (nested inside the `:linking` option) as follows:

```rb
spm_pkg "Foo",
        :path => "url/to/package",
        :linking => {
          :use_default_xcode_linking => true # <-- HERE
        }
```

While letting Xcode handles the linking is reliable, we might end up with some issues.

#### Duplicate symbols error

We often encounter the `Duplicate symbols` error during linking phases.

![](/docs/res/linking_error_duplicate_symbols.jpg)

This happens when the `-ObjC` linker flag is present (related: [here](https://forums.developer.apple.com/forums/thread/739396)). This seems to be an issue with the new linker (since Xcode 15).

A workaround for this issue is to switch to the old linker by adding the `-ld_classic` linker flag.\
Use the `:linker_flags` option (nested inside the `:linking` option) for this purpose.
```rb
spm_pkg "Foo",
        :path => "url/to/package",
        :linking => {
          :use_default_xcode_linking => true,
          :linker_flags => ["-ld_classic"] # <-- HERE
        }
```
