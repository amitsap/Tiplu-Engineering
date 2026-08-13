// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "TipluEngineering",
    platforms: [.macOS(.v13)],
    products: [
        .library(name: "TipluEngineering", targets: ["TipluEngineering"]),
    ],
    targets: [
        .target(name: "TipluEngineering"),
        .testTarget(name: "TipluEngineeringTests", dependencies: ["TipluEngineering"]),
    ]
)
