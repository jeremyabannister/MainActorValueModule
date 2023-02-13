//
//  MainActorValueSource.swift
//  
//
//  Created by Jeremy Bannister on 10/20/22.
//

///
public actor
    MainActorValueSource
        <Value>:
            Interface_SubscribableMainActorValue,
            Interface_MainActorValueSource,
            ReferenceType {
    
    ///
    public init (initialValue: Value) {
        self.init(
            _valueStorage: .value(initialValue)
        )
    }
    
    ///
    public init (uninitializedValue: @escaping @MainActor ()->Value) {
        self.init(
            _valueStorage: .notYetComputed(uninitializedValue)
        )
    }
    
    ///
    private init (_valueStorage: ValueStorage) {
        self._valueStorage = _valueStorage
    }
    
    ///
    @MainActor
    private var _valueStorage: ValueStorage
    
    ///
    private enum ValueStorage {
        case value (Value)
        case notYetComputed (@MainActor ()->Value)
    }
    
    ///
    private let _willSet = MainActorReactionManager<Void>()
    private let _didSet = MainActorReactionManager<Value>()
}

///
extension MainActorValueSource {
    
    ///
    public nonisolated var willSet: any Interface_MainActorReactionManager<Void> { _willSet }
    public nonisolated var didSet: any Interface_MainActorReactionManager<Value> { _didSet }
    
    ///
    @MainActor
    public var currentValue: Value {
        
        ///
        get {
            
            ///
            let valueToReturn: Value
            
            ///
            switch _valueStorage {
                
            ///
            case .value (let value):
                
                ///
                valueToReturn = value
                
            ///
            case .notYetComputed (let computeValue):
                
                ///
                let value = computeValue()
                
                ///
                self._valueStorage = .value(value)
                
                ///
                valueToReturn = value
            }
            
            ///
            MainActorValueSourceMonitor
                .shared
                .report(accessOf: self)
            
            ///
            return valueToReturn
        }
        
        ///
        set {
            
            ///
            for reaction in _willSet.orderedReactions {
                reaction(())
            }
            
            ///
            _valueStorage = .value(newValue)
            
            ///
            for reaction in _didSet.orderedReactions {
                reaction(newValue)
            }
        }
    }
    
    ///
    @MainActor
    public func setValue (to newValue: Value) {
        self.currentValue = newValue
    }
    
    ///
    @MainActor
    public func mutateValue (using mutation: (inout Value)->()) {
        var copy = currentValue
        mutation(&copy)
        self.currentValue = copy
    }
}
