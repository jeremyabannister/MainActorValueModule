//
//  SubscribableMainActorValueBinding.swift
//
//
//  Created by Jeremy Bannister on 7/26/24.
//

///
@_exported import MainActorValueModule_interface_main_actor_value_binding
@_exported import MainActorValueModule_interface_subscribable_main_actor_value
@_exported import MainActorValueModule_map


///
@MainActor
public struct SubscribableMainActorValueBinding<
    Value
>:
    Interface_MainActorValueBinding,
    Interface_SubscribableMainActorValue {
    
    ///
    private let subscribableValue: any Interface_SubscribableMainActorValue<Value>
    private let setValue: @MainActor (Value)->()
    
    ///
    public init(
        subscribableValue: any Interface_SubscribableMainActorValue<Value>,
        setValue: @escaping (Value)->()
    ) {
        self.subscribableValue = subscribableValue
        self.setValue = setValue
    }
    
    ///
    public var currentValue: Value {
        get { subscribableValue.currentValue }
        nonmutating set { setValue(newValue) }
    }
    
    ///
    public nonisolated var willSet: any Interface_MainActorReactionManager<Void> {
        subscribableValue.willSet
    }
    
    ///
    public nonisolated var didSet: any Interface_MainActorReactionManager<Value> {
        subscribableValue.didSet
    }
}

///
extension SubscribableMainActorValueBinding {
    
    ///
    public func map<
        NewValue
    >(
        _ keyPath: WritableKeyPath<Value, NewValue>
    ) -> SubscribableMainActorValueBinding<NewValue> {
        
        ///
        self.map(
            get: { $0[keyPath: keyPath] },
            set: { $0[keyPath: keyPath] = $1 }
        )
    }
    
    ///
    public func map<
        NewValue
    >(
        get: @escaping (Value)->NewValue,
        set: @escaping (inout Value, NewValue)->()
    ) -> SubscribableMainActorValueBinding<NewValue> {
        
        ///
        .init(
            subscribableValue: subscribableValue.map_subscribable(get),
            setValue: { set(&currentValue, $0) }
        )
    }
}
