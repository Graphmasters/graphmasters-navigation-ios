//  swift-tools-version:5.4
//  The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GraphmastersNavigation",
    products: [
        .library(
            name: "GraphmastersNavigation",
            targets: ["GraphmastersNavigation", "GraphmastersNavigationUtility"]
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
                "GraphmastersNavigationUtility",
                "GraphmastersNavigationNetworking",
                "GraphmastersNavigationCore",
            ]
        ),
        .target(
            name: "GraphmastersNavigationNetworking"
        ),
        .target(name: "GraphmastersNavigationUtility"),
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
