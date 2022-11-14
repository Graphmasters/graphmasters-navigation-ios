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
                "GraphamstersNavigationVoiceInstructions",
            ]
        ),
        .library(name: "GraphmastersNavigationCore", targets: ["GraphmastersNavigationCore"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
    ],
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
            name: "GraphamstersNavigationVoiceInstructions",
            dependencies: [
                "GraphmastersNavigationUtility",
                "GraphmastersNavigationCore",
                .product(name: "Logging", package: "swift-log"),
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
