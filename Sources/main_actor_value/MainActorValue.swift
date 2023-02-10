//
//  MainActorValue.swift
//  
//
//  Created by Jeremy Bannister on 10/20/22.
//

///
@_exported import MainActorValueModule_main_actor_value_source
@_exported import MainActorValueModule_reaction_hub


///
public actor MainActorValue <Value>:
    MainActorValueSource,
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
    private let _willSet = ReactionHub<Void>()
    private let _didSet = ReactionHub<Value>()
    private let _didAccess = ReactionHub<Value>()
}

///
extension MainActorValue {
    
    ///
    public nonisolated var rootObjectID: ObjectID {
        
        /// `MainActorValue` is an actual reference type (an "object") and therefore it is its own "rootObject", and therefore it returns its own objectID as the "rootObjectID".
        return self.objectID
    }
    
    ///
    public nonisolated var willSet: any MainActorReactionManager<Void> { _willSet }
    public nonisolated var didSet: any MainActorReactionManager<Value> { _didSet }
    public nonisolated var didAccess: any MainActorReactionManager<Value> { _didAccess }
    
    ///
    @MainActor
    public var currentValue: Value {
        
        ///
        get {
            
            ///
            func reportAccess (of value: Value) {
                for reaction in self._didAccess.orderedReactions {
                    reaction(value)
                }
            }
            
            ///
            switch _valueStorage {
                
            ///
            case .value (let value):
                
                ///
                reportAccess(of: value)
                
                ///
                return value
                
            ///
            case .notYetComputed (let computeValue):
                
                ///
                let value = computeValue()
                
                ///
                self._valueStorage = .value(value)
                
                ///
                reportAccess(of: value)
                
                ///
                return value
            }
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
