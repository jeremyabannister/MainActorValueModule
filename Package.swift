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
            "0.7.0" ..< "0.8.0"
        ),
    ],
    targets: expand([
        
        ///
        umbrellaTarget(
            name: "MainActorValueModule",
            submoduleDependencies: [
                "combine_compatibility",
                "main_actor_value",
                "main_actor_value_binding",
                "main_actor_value_source",
                "map",
            ]
        ),
        
        ///
        testedSubmoduleTarget(
            name: "combine_compatibility",
            submoduleDependencies: [
                "main_actor_value_source",
            ]
        ),
        submoduleTarget(
            name: "map",
            submoduleDependencies: [
                "main_actor_value",
            ]
        ),
        submoduleTarget(
            name: "main_actor_value",
            submoduleDependencies: [
                "interface_readable_main_actor_value",
            ]
        ),
        testedSubmoduleTarget(
            name: "main_actor_value_source",
            submoduleDependencies: [
                "interface_main_actor_value_binding",
                "interface_subscribable_main_actor_value",
                "main_actor_reaction_managers",
            ],
            otherDependencies: ["FoundationToolkit"]
        ),
        submoduleTarget(
            name: "main_actor_value_binding",
            submoduleDependencies: [
                "interface_main_actor_value_binding",
            ]
        ),
        submoduleTarget(
            name: "interface_subscribable_main_actor_value",
            submoduleDependencies: [
                "interface_main_actor_reaction_manager",
                "interface_readable_main_actor_value",
            ]
        ),
        submoduleTarget(
            name: "interface_main_actor_value_binding",
            submoduleDependencies: [
                "interface_readable_main_actor_value"
            ]
        ),
        submoduleTarget(
            name: "interface_readable_main_actor_value",
            submoduleDependencies: [
                "interface_main_actor_value_source_accessor"
            ]
        ),
        submoduleTarget(
            name: "interface_main_actor_value_source_accessor"
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
    ])
)

///
func umbrellaTarget
    (name: String,
     submoduleDependencies: [String] = [],
     otherDependencies: [Target.Dependency] = [])
-> Target {
    .target(
        name: name,
        dependencies: submoduleDependencies.map { .init(stringLiteral: submoduleName($0)) } + otherDependencies
    )
}
func testedSubmoduleTarget
    (name: String,
     submoduleDependencies: [String] = [],
     otherDependencies: [Target.Dependency] = [],
     nonstandardLocation: String? = nil)
-> [Target] {
    [
        submoduleTarget(
            name: name,
            submoduleDependencies: submoduleDependencies,
            otherDependencies: otherDependencies,
            nonstandardLocation: nonstandardLocation
        ),
        Target.testTarget(
            name: submoduleName(name) + "_tests",
            dependencies: [
                Target.Dependency(stringLiteral: submoduleName(name)),
                .product(name: "FoundationTestToolkit", package: "FoundationToolkit")
            ],
            path: "Tests/\(nonstandardLocation ?? name)"
        )
    ]
}
func submoduleTarget
    (name: String,
     submoduleDependencies: [String] = [],
     otherDependencies: [Target.Dependency] = [],
     nonstandardLocation: String? = nil)
-> Target {
    .target(
        name: submoduleName(name),
        dependencies: submoduleDependencies.map { .init(stringLiteral: submoduleName($0)) } + otherDependencies,
        path: "Sources/\(nonstandardLocation ?? name)"
    )
}
func submoduleName (_ name: String) -> String { "MainActorValueModule_\(name)" }



///
func expand (_ targetProviders: [any TargetProvider]) -> [Target] {
    targetProviders.flatMap { $0.targets() }
}

///
extension Target: TargetProvider {
    func targets () -> [Target] {
        [self]
    }
}

extension [Target]: TargetProvider {
    func targets () -> [Target] {
        self
    }
}

///
protocol TargetProvider {
    func targets () -> [Target]
}
