// swift-tools-version:5.7
import PackageDescription

let package = Package(
  name: "CoreUtils",
  products: [
    .library(name: "Swizzler", targets: ["Swizzler"]),
  ],
  targets: [
    .target(name: "Swizzler"),
  ]
)
