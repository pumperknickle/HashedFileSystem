// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "HashedFS",
    products: [
        .library(
            name: "HashedFS",
            targets: ["HashedFS"]),
    ],
    dependencies: [
        .package(url: "https://github.com/pumperknickle/Regenerate.git", from: "2.0.4"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "HashedFS",
            dependencies: ["Regenerate"]),
        .testTarget(
            name: "HashedFSTests",
            dependencies: ["HashedFS"]),
    ]
)
