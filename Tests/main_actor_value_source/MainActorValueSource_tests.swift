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
    func test_init_initialValue_withDeepChangeMonitoring() async {
        
        ///
        let rootLeakTracker = RootLeakTracker(name: #function)
        let leakTracker = rootLeakTracker.asLeakTracker
        
        ///
        var source: MainActorValueSource<MainActorValueSource<Bool>>! =
            .init(
                initialValue:
                    MainActorValueSource(
                        initialValue: false,
                        leakTracker: leakTracker["nestedSource"]
                    ),
                leakTracker: leakTracker["source"],
                withDeepChangeMonitoring: ()
            )
        
        ///
        var didSetOutput: MainActorValueSource<[Bool]>! =
            .init(
                initialValue: [],
                leakTracker: leakTracker["didSetOutput"]
            )
        
        ///
        source
            .didSet
            .registerReactionPermanently { output in
                didSetOutput
                    .mutateValue { $0.append(output.currentValue) }
            }
        
        ///
        try! didSetOutput
            .currentValue
            .assertEqual(to: [])
        
        ///
        source
            .currentValue
            .setValue(to: true)
        
        ///
        try! didSetOutput
            .currentValue
            .assertEqual(to: [true])
        
        ///
        source
            .currentValue
            .setValue(to: true)
        
        ///
        try! didSetOutput
            .currentValue
            .assertEqual(to: [true, true])
        
        ///
        source
            .setValue(
                to: .init(
                    initialValue: false,
                    leakTracker: leakTracker["newNestedSource"]
                )
            )
        
        ///
        try! didSetOutput
            .currentValue
            .assertEqual(to: [true, true, false])
        
        ///
        source = nil
        didSetOutput = nil
        
        ///
        try! rootLeakTracker.assertNoLeaks()
    }
    
    ///
    @MainActor
    func test_madeSubscribable() async {
        
        ///
        let rootLeakTracker = RootLeakTracker(name: #function)
        let leakTracker = rootLeakTracker.asLeakTracker
        
        ///
        var source: MainActorValueSource<Int>! =
            .init(
                initialValue: 7,
                leakTracker: leakTracker["source"]
            )
        
        ///
        var subscribableSource: SubscribableMainActorValue<Int>! =
            source
                .madeSubscribable(
                    leakTracker: leakTracker["subscribableSource"]
                )
        
        ///
        var reactionLog: MainActorValueSource<[Int]>! =
            .init(
                initialValue: [Int](),
                leakTracker: leakTracker["reactionLog"]
            )
        
        ///
        subscribableSource
            .didSet
            .registerReaction(key: "foo") { value in
                reactionLog
                    .mutateValue { $0.append(value) }
            }
        
        ///
        try! reactionLog
            .currentValue
            .assertEqual(to: [])
        
        ///
        try! await Task.sleep(seconds: 0.1)
        
        ///
        source.setValue(to: 8)
        
        ///
        try! await Task.sleep(seconds: 0.1)
        
        ///
        try! reactionLog
            .currentValue
            .assertEqual(to: [8])
        
        ///
        source = nil
        subscribableSource = nil
        reactionLog = nil
        
        ///
        try! rootLeakTracker.assertNoLeaks()
    }
}
