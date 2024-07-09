//
//  ObservableMainActorValue.swift
//  
//
//  Created by Jeremy Bannister on 2/5/23.
//

///
public final class ObservableMainActorValue<
    Value
>: ObservableObject,
   Interface_ReadableMainActorValue {
    
    ///
    public let objectWillChange: AnyPublisher<Void, Never>
    
    ///
    private let value: any Interface_ReadableMainActorValue<Value>
    
    ///
    @MainActor
    public var currentValue: Value {
        value.currentValue
    }
    
    ///
    @MainActor
    public init(
        _ value: some Interface_ReadableMainActorValue<Value>,
        leakTracker: LeakTracker
    ) {
        
        ///
        self.value = value
        
        ///
        self.objectWillChange =
            MainActorValueWillChangePublisher(
                readOnlyValue: value,
                leakTracker: leakTracker
            )
                .map { _ in () }
                .eraseToAnyPublisher()
        
        ///
        leakTracker.track(self)
    }
    
    ///
    public init(_ value: some Interface_SubscribableMainActorValue<Value>) {
        
        ///
        self.value = value
        
        ///
        self.objectWillChange =
            MainActorValueWillChangePublisher(
                subscribableValue: value
            )
                .map { _ in () }
                .eraseToAnyPublisher()
    }
}

///
extension Interface_ReadableMainActorValue {
    
    ///
    @MainActor
    public func asObservableMainActorValue(
        leakTracker: LeakTracker
    ) -> ObservableMainActorValue<Value> {
        
        ///
        .init(
            self,
            leakTracker: leakTracker
        )
    }
}

///
extension Interface_SubscribableMainActorValue {
    
    ///
    public func asObservableMainActorValue() -> ObservableMainActorValue<Value> {
        .init(self)
    }
}
