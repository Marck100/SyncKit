// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SyncKit",
    platforms: [
        .iOS(.v8),
        .macOS(.v10_10),
    ],
    products: [
        .library(
            name: "SyncKit",
            targets: ["SyncKit"]),
    ],
    targets: [
        .target(
            name: "SyncKit",
            dependencies: []),
        .testTarget(
            name: "SyncKitTests",
            dependencies: ["SyncKit"]),
    ]
)
