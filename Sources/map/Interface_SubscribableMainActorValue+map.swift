//
//  Interface_SubscribableMainActorValue+map.swift
//
//
//  Created by Jeremy Bannister on 2/28/24.
//

///
extension Interface_SubscribableMainActorValue {
    
    ///
    public func map_subscribable<
        NewValue
    >(
        _ transform: @escaping (Value)->NewValue
    ) -> any Interface_SubscribableMainActorValue<NewValue> {
        
        ///
        SubscribableMainActorValue(
            getCurrentValue: { transform(self.currentValue) },
            willSet: self.willSet,
            didSet: self.didSet.map { transform($0) }
        )
    }
}

///
private struct SubscribableMainActorValue<Value>: Interface_SubscribableMainActorValue {
    
    ///
    var currentValue: Value { getCurrentValue() }
    let willSet: any Interface_MainActorReactionManager<Void>
    let didSet: any Interface_MainActorReactionManager<Value>
    
    ///
    private let getCurrentValue: @MainActor ()->Value
    
    ///
    init(
        getCurrentValue: @escaping @MainActor ()->Value,
        willSet: any Interface_MainActorReactionManager<Void>,
        didSet: any Interface_MainActorReactionManager<Value>
    ) {
        self.getCurrentValue = getCurrentValue
        self.willSet = willSet
        self.didSet = didSet
    }
}
