//  swift-tools-version:5.4
//  The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GraphmastersNavigationCore",
    products: [
        .library(
            name: "GraphmastersNavigationCore",
            targets: ["GraphmastersNavigationCore"]
        ),
    ],
    dependencies: [],
    targets: [
        .binaryTarget(
            name: "GraphmastersNavigationCore",
            path: "Sources/GraphmastersNavigationCore/GraphmastersNavigationCore.xcframework"
        ),
        .testTarget(
            name: "GraphmastersNavigationCoreTests",
            dependencies: ["GraphmastersNavigationCore"]
        ),
    ]
)
