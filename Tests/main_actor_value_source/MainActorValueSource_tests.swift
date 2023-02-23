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
    func test_init_initialValue_withDeepChangeMonitoring () async throws {
        
        ///
        let source =
            MainActorValueSource(
                initialValue: MainActorValueSource(initialValue: false),
                withDeepChangeMonitoring: ()
            )
        
        ///
        let didSetOutput = MainActorValueSource<[Bool]>(initialValue: [])
        
        ///
        source
            .didSet
            .registerReactionPermanently { output in
                didSetOutput
                    .mutateValue { $0.append(output.currentValue) }
            }
        
        ///
        try didSetOutput
            .currentValue
            .assertEqual(to: [])
        
        ///
        source
            .currentValue
            .setValue(to: true)
        
        ///
        try didSetOutput
            .currentValue
            .assertEqual(to: [true])
        
        ///
        source
            .currentValue
            .setValue(to: true)
        
        ///
        try didSetOutput
            .currentValue
            .assertEqual(to: [true, true])
        
        ///
        source
            .setValue(to: .init(initialValue: false))
        
        ///
        try didSetOutput
            .currentValue
            .assertEqual(to: [true, true, false])
    }
    
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
        try await Task.sleep(seconds: 0.1)
        
        ///
        source.setValue(to: 8)
        
        ///
        try await Task.sleep(seconds: 0.1)
        
        ///
        try reactionLog
            .currentValue
            .assertEqual(to: [8])
    }
}
