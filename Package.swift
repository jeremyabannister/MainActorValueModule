// swift-tools-version: 5.7

///
import PackageDescription

///
let package = Package(
    name: "MainActorValueModule",
    platforms: [.macOS(.v13), .iOS(.v16), .watchOS(.v6), .tvOS(.v13)],
    products: [
        .library(
            name: "MainActorValueModule",
            targets: ["MainActorValueModule"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/jeremyabannister/FoundationToolkit",
            from: "0.4.4"
        ),
    ],
    targets: [
        
        ///
        umbrellaTarget(
            name: "MainActorValueModule",
            submoduleDependencies: [
                "combine_compatibility",
                "ergonomics",
                "main_actor_value",
                "map",
            ]
        ),
        
        ///
        submoduleTarget(
            name: "combine_compatibility",
            submoduleDependencies: [
                "ergonomics",
                "main_actor_value",
            ]
        ),
        submoduleTarget(
            name: "map",
            submoduleDependencies: ["main_actor_value"]
        ),
        submoduleTarget(
            name: "ergonomics",
            submoduleDependencies: ["main_actor_value_accessor"]
        ),
        submoduleTarget(
            name: "main_actor_value",
            submoduleDependencies: [
                "main_actor_value_source",
                "reaction_hub",
            ]
        ),
        submoduleTarget(
            name: "reaction_hub",
            submoduleDependencies: ["main_actor_value_accessor"]
        ),
        submoduleTarget(
            name: "main_actor_value_source",
            submoduleDependencies: ["main_actor_value_accessor"]
        ),
        submoduleTarget(
            name: "main_actor_value_accessor",
            otherDependencies: ["FoundationToolkit"]
        ),
        
        ///
        .testTarget(
            name: "MainActorValueModule-tests",
            dependencies: ["MainActorValueModule"]
        ),
    ]
)

///
func umbrellaTarget
    (name: String,
     submoduleDependencies: [String] = [],
     otherDependencies: [Target.Dependency] = [])
-> Target {
    .target(
        name: name,
        dependencies:
            submoduleDependencies
                .map { .init(stringLiteral: submoduleName($0)) }
            + otherDependencies
    )
}
func submoduleTarget
    (name: String,
     submoduleDependencies: [String] = [],
     otherDependencies: [Target.Dependency] = [])
-> Target {
    .target(
        name: submoduleName(name),
        dependencies:
            submoduleDependencies
                .map { .init(stringLiteral: submoduleName($0)) }
            + otherDependencies,
        path: "Sources/\(name)"
    )
}
func submoduleName (_ name: String) -> String { "MainActorValueModule_\(name)" }
