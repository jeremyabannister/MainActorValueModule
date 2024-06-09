//
//  SubscribableMainActorValue.swift
//  
//
//  Created by Jeremy Bannister on 2/10/23.
//

///
extension Interface_ReadableMainActorValue {
    
    ///
    @MainActor
    public func madeSubscribable(
        leakTracker: LeakTracker
    ) -> SubscribableMainActorValue<Value> {
        
        ///
        SubscribableMainActorValue(
            readableValue: self,
            leakTracker: leakTracker
        )
    }
}

///
@MainActor
public final class SubscribableMainActorValue<Value>: Interface_SubscribableMainActorValue {
    
    ///
    public convenience init(
        readableValue: any Interface_ReadableMainActorValue<Value>,
        leakTracker: LeakTracker
    ) {
        
        ///
        self.init(
            generateValue: { readableValue.currentValue },
            leakTracker: leakTracker
        )
    }
    
    ///
    public init(
        generateValue: @escaping @MainActor ()->Value,
        leakTracker: LeakTracker
    ) {
        
        ///
        let optionalGenerateValueClosure: MainActorClosure_0Inputs<Value?> =
            .init { generateValue() }
        
        ///
        self.generateValue = generateValue
        self.optionalGenerateValueClosure = optionalGenerateValueClosure
        
        ///
        let _willSet =
            MainActorReactionManager<Void>(
                leakTracker: leakTracker["_willSet"]
            )
        let _didSet =
            MainActorReactionManager<Value>(
                leakTracker: leakTracker["_didSet"]
            )
        
        ///
        self._willSet = _willSet
        self._didSet = _didSet
        
        ///
        leakTracker.track(self)
        
        ///
        setupChangeNotificationForwarding(
            sourceObjectID: nil,
            generateValue: optionalGenerateValueClosure,
            _willSet: _willSet,
            _didSet: _didSet,
            leakTracker: leakTracker
        )
    }
    
    ///
    private let generateValue: @MainActor ()->Value
    private let optionalGenerateValueClosure: MainActorClosure_0Inputs<Value?>
    
    ///
    private let id = UUID()
    
    ///
    @MainActor
    public var currentValue: Value {
        
        ///
        return generateValue()
    }
    
    ///
    private let _willSet: MainActorReactionManager<Void>
    private let _didSet: MainActorReactionManager<Value>
    
    ///
    public nonisolated var willSet: any Interface_MainActorReactionManager<Void> {
        _willSet
    }
    
    ///
    public nonisolated var didSet: any Interface_MainActorReactionManager<Value> {
        _didSet
    }
}
