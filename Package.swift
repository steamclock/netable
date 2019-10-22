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
    .package(url: "https://github.com/kylef/Mockingjay", .exact("3.0.0-alpha.1"))
  ],
  targets: [
    .target(
      name: "SCNetworkAPIMobile",
      path: "SCNetworkAPI/Source"
    ),
    .testTarget(
      name: "SCNetworkAPIMobileTests",
      dependencies: [
        "SCNetworkAPIMobile",
        "Mockingjay"
      ]),
      path: "SCNetworkAPI/Tests"
  ]
)
