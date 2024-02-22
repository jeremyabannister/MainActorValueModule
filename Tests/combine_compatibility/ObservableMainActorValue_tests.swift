//
//  ObservableMainActorValue_tests.swift
//  
//
//  Created by Jeremy Bannister on 2/18/23.
//

///
final class Interface_ReadableMainActorValue_tests: XCTestCase {
    
    ///
    @MainActor
    func test_asObservableMainActorValue() async {
        
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
        func createObservable<
            Value
        >(
            using readOnly: some Interface_ReadableMainActorValue<Value>
        ) -> ObservableMainActorValue<Value> {
            
            ///
            readOnly.asObservableMainActorValue(
                leakTracker: leakTracker["observable"]
            )
        }
        
        ///
        var observable: ObservableMainActorValue<Int>! = createObservable(using: source)
        
        ///
        var willChangeCount: MainActorValueSource<Int>! =
            .init(
                initialValue: 0,
                leakTracker: leakTracker["willChangeCount"]
            )
        
        ///
        @MainActor
        func assertChangeCount (_ count: Int) throws {
            try willChangeCount
                .currentValue
                .assertEqual(to: count)
        }
        
        ///
        var subscription: Any! =
            observable
                .objectWillChange
                .sink { [willChangeCount] in
                    Task { @MainActor in
                        willChangeCount?
                            .mutateValue { $0 += 1 }
                    }
                }
        _ = subscription
        
        ///
        @MainActor
        func assert(
            value: Int,
            changeCount: Int
        ) throws {
            try observable.currentValue.assertEqual(to: value)
            try assertChangeCount(changeCount)
        }
        
        ///
        @MainActor
        func setAndAssert(
            value: Int,
            changeCount: Int
        ) async throws {
            source.setValue(to: value)
            try await Task.sleep(seconds: 0.1)
            try assert(value: value, changeCount: changeCount)
        }
        
        ///
        try! await Task.sleep(seconds: 0.1)
        try! assert(value: 7, changeCount: 0)
        try! await setAndAssert(value: 8, changeCount: 1)
        try! await setAndAssert(value: 8, changeCount: 2)
        try! await setAndAssert(value: 0, changeCount: 3)
        
        ///
        source = nil
        observable = nil
        willChangeCount = nil
        subscription = nil
        
        ///
        try? await Task.sleep(for: .seconds(1))
        
        ///
        try! rootLeakTracker.assertNoLeaks()
    }
}
