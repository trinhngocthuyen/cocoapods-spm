# Demo for cocoapods-spm Integration

## Highlights

- Declare SPM packages in Podfile: [Podfile#L30-L40](/examples/Podfile#L30-L40)
- Declare SPM dependencies in podspecs: [LocalPods/CommonUI/CommonUI.podspec#L4](/examples/LocalPods/CommonUI/CommonUI.podspec#L4)
- Declare prebuilt macro in Podfile: [Podfile#L21-L24](/examples/Podfile#L21-L24).\
Then, other pods can depend on it just like normal: [LocalPods/CommonUI/CommonUI.podspec#L3](/examples/LocalPods/CommonUI/CommonUI.podspec#L3)

### Config

Check out the sample config at [Podfile#L12-L15](/examples/Podfile#L12-L15):

```rb
config_cocoapods_spm(
  dont_prebuild_macros: true,
  default_macro_config: "debug"
)
```
The `dont_prebuild_macros` option as `true` means: do not prebuild macros (if not exist) during pod installation. We can prebuild them using the CLI. With this option as `false`, the prebuild will be triggered upon pod installation.
