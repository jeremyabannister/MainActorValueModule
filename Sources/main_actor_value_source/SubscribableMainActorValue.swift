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
    public func madeSubscribable () -> SubscribableMainActorValue<Value> {
        SubscribableMainActorValue(
            readableValue: self
        )
    }
}

///
public actor
    SubscribableMainActorValue
        <Value>:
            Interface_SubscribableMainActorValue {
    
    ///
    @MainActor
    public init (readableValue: any Interface_ReadableMainActorValue<Value>) {
        self.init({ readableValue.currentValue })
    }
    
    ///
    @MainActor
    public init (_ generateValue: @escaping @MainActor ()->Value) {
        
        ///
        self.generateValue = generateValue
        
        ///
        let _willSet = MainActorReactionManager<Void>()
        let _didSet = MainActorReactionManager<Value>()
        
        ///
        self._willSet = _willSet
        self._didSet = _didSet
        
        ///
        setupChangeNotificationForwarding(
            sourceObjectID: nil,
            generateValue: generateValue,
            _willSet: _willSet,
            _didSet: _didSet
        )
    }
    
    ///
    private let generateValue: @MainActor ()->Value
    
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
