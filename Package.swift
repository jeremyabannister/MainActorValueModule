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
                "main_actor_value",
                "map",
            ]
        ),
        
        ///
        submoduleTarget(
            name: "combine_compatibility",
            submoduleDependencies: [
                "main_actor_value",
                "subscribable_main_actor_value_accessor",
            ]
        ),
        submoduleTarget(
            name: "map",
            submoduleDependencies: [
                "main_actor_value",
            ]
        ),
        submoduleTarget(
            name: "subscribable_main_actor_value_accessor",
            submoduleDependencies: [
                "main_actor_value_source_monitor",
            ]
        ),
        submoduleTarget(
            name: "main_actor_value",
            submoduleDependencies: [
                "main_actor_value_source",
                "main_actor_value_source_monitor",
            ]
        ),
        submoduleTarget(
            name: "main_actor_value_source_monitor",
            submoduleDependencies: [
                "main_actor_value_source",
            ]
        ),
        submoduleTarget(
            name: "main_actor_value_source",
            submoduleDependencies: [
                "main_actor_value_accessor",
                "main_actor_reaction_managers",
            ]
        ),
        submoduleTarget(
            name: "main_actor_value_accessor",
            submoduleDependencies: ["interface_main_actor_reaction_manager"],
            otherDependencies: ["FoundationToolkit"]
        ),
        
        
        ///
        submoduleTarget(
            name: "main_actor_reaction_managers",
            submoduleDependencies: [
                "mapped_main_actor_reaction_manager",
                "main_actor_reaction_manager",
                "ergonomics_interface_main_actor_reaction_manager",
                "interface_main_actor_reaction_manager",
            ]
        ),
        submoduleTarget(
            name: "mapped_main_actor_reaction_manager",
            submoduleDependencies: ["interface_main_actor_reaction_manager"]
        ),
        submoduleTarget(
            name: "main_actor_reaction_manager",
            submoduleDependencies: ["interface_main_actor_reaction_manager"]
        ),
        submoduleTarget(
            name: "ergonomics_interface_main_actor_reaction_manager",
            submoduleDependencies: ["interface_main_actor_reaction_manager"]
        ),
        submoduleTarget(
            name: "interface_main_actor_reaction_manager"
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
