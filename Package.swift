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
                "GraphmastersNavigationCore",
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
            name: "GraphamstersNavigationVoiceInstructions",
            dependencies: [
                "GraphmastersNavigationCore",
                .product(name: "Logging", package: "swift-log"),
            ]
        ),
        .testTarget(
            name: "GraphmastersNavigationCoreTests",
            dependencies: ["GraphmastersNavigationCore"]
        ),
    ]
)
