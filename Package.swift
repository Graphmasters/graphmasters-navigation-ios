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
                "GraphmastersNavigationCore",
                "GraphmastersNavigationVoiceInstructions",
            ]
        ),
        .library(name: "GraphmastersNavigationCore", targets: ["GraphmastersNavigationCore"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "GraphmastersNavigation",
            resources: [
                .process("Resources/PrivacyInfo.xcprivacy")
            ]
        ),
        .binaryTarget(
            name: "GraphmastersNavigationCore",
            path: "Sources/GraphmastersNavigationCore/GraphmastersNavigationCore.xcframework"
        ),
        .target(
            name: "GraphmastersNavigationVoiceInstructions",
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
