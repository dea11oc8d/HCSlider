// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "HCSlider",
    platforms: [
        .iOS(.v13),
    ],
    products: [
        .library(
            name: "HCSlider",
            targets: ["HCSlider"]),
    ],
    targets: [
        .target(
            name: "HCSlider",
            resources: [.process("Resources/Assets.xcassets")]),
        .testTarget(
            name: "HCSliderTests",
            dependencies: ["HCSlider"]),
    ]
)
