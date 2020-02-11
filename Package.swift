// swift-tools-version:5.1
import PackageDescription

let package = Package(
  name: "Netable",
  platforms: [
    .iOS(.v12), .macOS(.v10_14)
  ],
  products: [
    .library(
      name: "Netable",
      targets: ["Netable"]
    )
  ],
  dependencies: [
  ],
  targets: [
    .target(
      name: "Netable",
      path: "Netable/Netable"
    )
  ]
)
