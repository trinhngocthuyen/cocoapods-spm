// swift-tools-version:5.7
import PackageDescription

let package = Package(
  name: "CoreUtils",
  products: [
    .library(name: "Swizzler", targets: ["Swizzler"]),
    .library(name: "TestKit", targets: ["TestKit"]),
  ],
  targets: [
    .target(name: "Swizzler"),
    .target(name: "TestKit"),
  ]
)
