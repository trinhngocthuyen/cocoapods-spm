[< Documentation](README.md)

# Under the Hood: Swift Binary Macros

This technique was inspired by the approach mentioned in [this blog post](https://www.polpiella.dev/binary-swift-macros).

### Overview

The process of turning a package into a pod can be summarized in the following steps:
- Step (1): Prepare a dedicated pod dir: `.spm.pods/macros/<Package>`

- Step (2): Download the source of that package into: `.spm.pods/macros/.download/<Package>`

- Step (3): Prebuild the macro implementation.\
Place it under `.spm.pods/macros/.prebuilt/<Package>/<Binary>-<config>`

- Step (4): Copy the source files of the macro interfaces,\
from `.spm.pods/macros/.download/<Package>/Sources/<Interfaces>`\
to `.spm.pods/macros/<Package>/Sources/<Interfaces>`

The dir structure of `.spm.pods` looks like this:

```
.spm.pods / --- PackageA / --- PackageA.podspec
           |              |--- Sources / --- Interfaces / --- Interfaces.swift
           |
           |--- .prebuilt / --- PackageA / --- Binary-debug (*)
           |                              |--- Binary-release (*)
           |
           |--- .download / --- PackageA / --- Package.swift
                                          |--- Sources / --- Interfaces / --- Interfaces.swift
                                                        |--- Implementation / MacroA.swift
```
