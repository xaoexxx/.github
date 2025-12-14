// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ExxSystem",
    platforms: [
        .macOS(.v13),
        .iOS(.v16)
    ],
    products: [
        .executable(
            name: "exx",
            targets: ["ExxCLI"]
        ),
        .library(
            name: "ExxSystem",
            targets: ["ExxSystem"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "ExxSystem",
            dependencies: [],
            path: "Sources/ExxSystem"
        ),
        .executableTarget(
            name: "ExxCLI",
            dependencies: ["ExxSystem"],
            path: "Sources/ExxCLI"
        ),
        .testTarget(
            name: "ExxSystemTests",
            dependencies: ["ExxSystem"],
            path: "Tests"
        ),
    ]
)
