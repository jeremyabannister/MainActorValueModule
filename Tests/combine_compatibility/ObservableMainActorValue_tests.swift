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
    func test_asObservableMainActorValue () async {
        
        ///
        let source = MainActorValueSource(initialValue: 7)
        
        ///
        func createObservable
            <Value>
            (using readOnly: some Interface_ReadableMainActorValue<Value>)
        -> ObservableMainActorValue<Value> {
            
            ///
            readOnly.asObservableMainActorValue()
        }
        
        ///
        let observable = createObservable(using: source)
        
        ///
        let willChangeCount = MainActorValueSource(initialValue: 0)
        
        ///
        @MainActor
        func assertChangeCount (_ count: Int) throws {
            try willChangeCount
                .currentValue
                .assertEqual(to: count)
        }
        
        ///
        let subscription =
            observable
                .objectWillChange
                .sink { [willChangeCount] in
                    Task { @MainActor in
                        willChangeCount
                            .mutateValue { $0 += 1 }
                    }
                }
        _ = subscription
        
        ///
        @MainActor
        func assert
            (value: Int,
             changeCount: Int)
        throws {
            try observable.currentValue.assertEqual(to: value)
            try assertChangeCount(changeCount)
        }
        
        ///
        @MainActor
        func setAndAssert
            (value: Int,
             changeCount: Int)
        async throws {
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
    }
}
