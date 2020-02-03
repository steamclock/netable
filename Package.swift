// swift-tools-version:5.1
import PackageDescription

let package = Package(
  name: "SCNetworkAPI",
  platforms: [
    .iOS(.v12), .macOS(.v10_14)
  ],
  products: [
    .library(
      name: "SCNetworkAPI",
      targets: ["SCNetworkAPIMobile"]
    )
  ],
  dependencies: [
  ],
  targets: [
    .target(
      name: "SCNetworkAPIMobile",
      path: "SCNetworkAPI/Source"
    )
  ]
)
