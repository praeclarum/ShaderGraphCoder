// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ShaderGraphCoder",
    platforms: [.visionOS(.v1), .iOS(.v13), .watchOS(.v6), .tvOS(.v13), .macOS(.v10_15)],
    products: [
        .library(
            name: "ShaderGraphCoder",
            targets: ["ShaderGraphCoder"]),
    ],
    targets: [
        .target(
            name: "ShaderGraphCoder"),
        .testTarget(
            name: "ShaderGraphCoderTests",
            dependencies: ["ShaderGraphCoder"],
            resources: [.process("Resources/TestTexture.png")]),
    ]
)
