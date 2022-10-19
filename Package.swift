//  swift-tools-version:5.4
//  The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GraphmastersNavigation",
    platforms: [.iOS(.v11)],
    products: [
        .library(
            name: "GraphmastersNavigation",
            targets: [
                "GraphmastersNavigation",
            ]
        ),
        .library(name: "GraphmastersNavigationCore", targets: ["GraphmastersNavigationCore"]),
    ],
    dependencies: [],
    targets: [
        .binaryTarget(
            name: "GraphmastersNavigationCore",
            path: "Sources/GraphmastersNavigationCore/GraphmastersNavigationCore.xcframework"
        ),
        .target(
            name: "GraphmastersNavigation",
            dependencies: [
                "GraphmastersNavigationUtility",
                "GraphmastersNavigationNetworking",
                "GraphmastersNavigationCore",
            ]
        ),
        .target(
            name: "GraphmastersNavigationNetworking",
            dependencies: ["GraphmastersNavigationCore"]
        ),
        .target(name: "GraphmastersNavigationUtility"),
        .testTarget(
            name: "GraphmastersNavigationCoreTests",
            dependencies: ["GraphmastersNavigationCore"]
        ),
    ]
)
