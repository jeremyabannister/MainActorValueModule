//
//  main_actor_reaction_managers_tests.swift
//  
//
//  Created by Jeremy Bannister on 9/27/23.
//

///
@_exported import MainActorValueModule_main_actor_reaction_managers
@_exported import FoundationTestToolkit


///
final class main_actor_reaction_managers_tests: XCTestCase {
    
    ///
    @MainActor
    func test_for_leaks() async {
        
        ///
        let rootLeakTracker = RootLeakTracker(name: #function)
        let leakTracker = rootLeakTracker.asLeakTracker
        
        ///
        var manager: MainActorReactionManager<String>! = .init(leakTracker: leakTracker["manager"])
        var mapped: MappedMainActorReactionManager<String, Int>! = manager.map { $0.count }
        mapped.registerReactionPermanently { _ in }
        
        ///
        manager = nil
        mapped = nil
        
        ///
        try? await Task.sleep(for: .seconds(1))
        
        ///
        try! rootLeakTracker.assertNoLeaks()
    }
}
