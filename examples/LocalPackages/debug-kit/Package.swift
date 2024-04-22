// swift-tools-version:5.7
import PackageDescription

let package = Package(
  name: "DebugKit",
  products: [
    .library(name: "DebugKit", targets: ["DebugKit"]),
  ],
  dependencies: [],
  targets: [
    .target(name: "DebugKit", dependencies: ["NetworkLoggerFramework"]),
    .binaryTarget(name: "NetworkLoggerFramework", path: "Frameworks/NetworkLogger.xcframework.zip"),
  ]
)
