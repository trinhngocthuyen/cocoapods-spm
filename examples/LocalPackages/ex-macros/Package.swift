// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let package = Package(
  name: "Wizard",
  platforms: [.macOS(.v11), .iOS(.v14), .tvOS(.v13), .watchOS(.v6), .macCatalyst(.v13)],
  products: [
    .library(
      name: "Wizard",
      targets: ["Wizard"]
    ),
    .executable(
      name: "WizardPlayground",
      targets: ["WizardPlayground"]
    ),
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-syntax.git", from: "509.0.0"),
    .package(url: "https://github.com/stackotter/swift-macro-toolkit.git", from: "0.3.1"),
  ],
  targets: [
    .macro(
      name: "WizardImpl",
      dependencies: [
        .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
        .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
        .product(name: "MacroToolkit", package: "swift-macro-toolkit"),
      ]
    ),
    .target(name: "Wizard", dependencies: ["WizardImpl"]),
    .executableTarget(name: "WizardPlayground", dependencies: ["Wizard"]),
  ]
)
