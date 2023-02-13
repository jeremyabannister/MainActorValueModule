//
//  MainActorValueSource_tests.swift
//  
//
//  Created by Jeremy Bannister on 2/13/23.
//

///
final class MainActorValueSource_tests: XCTestCase {
    
    ///
    @MainActor
    func test_madeSubscribable () async throws {
        
        ///
        let source = MainActorValueSource(initialValue: 7)
        
        ///
        let subscribableSource = source.madeSubscribable()
        
        ///
        let reactionLog = MainActorValueSource(initialValue: [Int]())
        
        ///
        subscribableSource
            .didSet
            .registerReaction(key: "foo") { value in
                reactionLog
                    .mutateValue { $0.append(value) }
            }
        
        ///
        try reactionLog
            .currentValue
            .assertEqual(to: [])
        
        ///
        source.setValue(to: 8)
        
        ///
        try reactionLog
            .currentValue
            .assertEqual(to: [8])
    }
}
