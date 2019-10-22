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
  targets: [
    .target(
      name: "SCNetworkAPIMobile",
      path: "SCNetworkAPI/Source"
    ),
    .testTarget(
      name: "SCNetworkAPIMobileTests",
      path: "SCNetworkAPI/Tests",
      dependencies: [
        "SCNetworkAPIMobile",
        .package(url: "https://github.com/kylef/Mockingjay", .exact("3.0.0-alpha.1"))
      ])
  ]
)
