# Using With xcodebuild

## Custom SourcePackages dir (via `-clonedSourcePackagesDirPath`)
The plugin should work with both Xcode and xcodebuild.

The plugin uses the `SOURCE_PACKAGES_CHECKOUTS_DIR` setting (resolved from `BUILD_ROOT`) to handle linking and other build configurations. This corresponds to the SourcePackages dir (containing SPM packages' sources). If you use a custom SourcePackages dir in xcodebuild, via the `-clonedSourcePackagesDirPath` argument, the plugin cannot infer this dir correctly. In this case, please pass the `SOURCE_PACKAGES_CHECKOUTS_DIR` setting (*absolute path*) to the xcodebuild command.

```sh
xcodebuild archive \
  -workspace App.workspace \
  -scheme App \
  ... \
  -clonedSourcePackagesDirPath=a/b/c \
  ...
  SOURCE_PACKAGES_CHECKOUTS_DIR=a/b/c # <---HERE
```
