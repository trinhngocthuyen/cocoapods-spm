// swift-tools-version:5.7
import PackageDescription

let package = Package(
  name: "DebugKit",
  products: [
    .library(name: "DebugKit", targets: ["DebugKit"]),
  ],
  dependencies: [
    .package(path: "../core-utils"),
  ],
  targets: [
    .target(
      name: "DebugKit",
      dependencies: [
        "DebugKitObjC",
        "NetworkLoggerFramework",
        .product(name: "Swizzler", package: "core-utils"),
      ],
      resources: [
        .copy("Resources/DebugKit.trace"),
      ]
    ),
    .target(name: "DebugKitObjC"),
    .binaryTarget(name: "NetworkLoggerFramework", path: "Frameworks/NetworkLogger.xcframework.zip"),
  ]
)
