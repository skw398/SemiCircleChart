// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SemiCircleChart",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "SemiCircleChart",
            targets: ["SemiCircleChart"]),
    ],
    targets: [
        .target(
            name: "SemiCircleChart",
            dependencies: [])
    ]
)

