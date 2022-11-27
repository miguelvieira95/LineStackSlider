// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "LineStackSlider",
    platforms: [
        .iOS(.v13),
    ],
    products: [
        .library(
            name: "LineStackSlider",
            targets: ["LineStackSlider"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "LineStackSlider",
            dependencies: [])
    ]
)
