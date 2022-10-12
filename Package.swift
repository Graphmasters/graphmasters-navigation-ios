//  swift-tools-version:5.4
//  The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GraphmastersNavigation",
    products: [
        .library(
            name: "GraphmastersNavigation",
            targets: ["GraphmastersNavigation", "GraphmastersNavigationNetworking"]
        ),
        .library(
            name: "GraphmastersNavigationCore",
            targets: ["GraphmastersNavigationCore"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "GraphmastersNavigation",
            dependencies: [
                "GraphmastersNavigationNetworking",
                "GraphmastersNavigationCore",
            ]
        ),
        .target(
            name: "GraphmastersNavigationNetworking"
        ),
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
