// swift-tools-version: 5.7

///
import PackageDescription

///
let package = Package(
    name: "MainActorValueModule",
    platforms: [.macOS(.v10_15), .iOS(.v13), .watchOS(.v6), .tvOS(.v13)],
    products: [
        .library(
            name: "MainActorValueModule",
            targets: ["MainActorValueModule"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/jeremyabannister/FoundationToolkit",
            from: "0.4.0"
        ),
    ],
    targets: [
        .target(
            name: "MainActorValueModule",
            dependencies: ["concrete"]
        ),
        .target(
            name: "concrete",
            dependencies: ["abstract"]
        ),
        .target(
            name: "abstract",
            dependencies: ["FoundationToolkit"]
        ),
        .testTarget(
            name: "MainActorValueModule-tests",
            dependencies: ["MainActorValueModule"]
        ),
    ]
)
