//
//  MainActorValue.swift
//  
//
//  Created by Jeremy Bannister on 10/20/22.
//

///
@_exported import MainActorValueModule_abstract


///
public actor MainActorValue <Value>:
    MainActorValueAccessor,
    ReferenceType {
    
    ///
    public init (initialValue: Value) {
        self._valueStorage = .value(initialValue)
    }
    
    ///
    public init (uninitializedValue: @escaping @MainActor ()->Value) {
        self._valueStorage = .notYetComputed(uninitializedValue)
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
    public nonisolated var willSet: any MainActorReactionManager<Value> { _willSet }
    public nonisolated var didSet: any MainActorReactionManager<Value> { _didSet }
    
    ///
    private let _willSet = ReactionHub<Value>()
    private let _didSet = ReactionHub<Value>()
    
    ///
    public nonisolated var rootObjectID: ObjectID {
        self.objectID
    }
    
    ///
    @MainActor
    public var currentValue: Value {
        
        ///
        get {
            
            ///
            switch _valueStorage {
            case .value (let value):
                return value
                
            case .notYetComputed (let computeValue):
                return computeValue()
            }
        }
        
        ///
        set {
            
            ///
            for reaction in _willSet.orderedReactions {
                reaction(newValue)
            }
            
            ///
            _valueStorage = .value(newValue)
            
            ///
            for reaction in _didSet.orderedReactions {
                reaction(newValue)
            }
        }
    }
}

///
extension MainActorValue {
    
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

///
extension MainActorValue {
    
    ///
    @available(*, deprecated, message: "Use `currentValue` instead, this property will be removed soon.")
    @MainActor
    public var value: Value {
        get { currentValue }
        set { currentValue = newValue }
    }
}

///
public actor ReactionHub <Event>: MainActorReactionManager {
    
    ///
    public init () { }
    
    ///
    @MainActor
    private var reactions: [String: @MainActor (Event)->()] = [:]
    
    ///
    @MainActor
    private var orderedReactionKeys: [String] = []
    
    ///
    @MainActor
    internal var orderedReactions: [@MainActor (Event)->()] {
        orderedReactionKeys
            .compactMap { reactions[$0] }
    }
    
    ///
    public nonisolated func registerReaction_weakClosure
        (key: String,
         _ reaction: @escaping @MainActor (Event)->())
    -> @MainActor ()->() {
        
        ///
        return { [weak self] in
            
            ///
            guard let self else { return }
            
            ///
            if self.reactions.keys.contains(key) {
                
                ///
                self.orderedReactionKeys.removeAll(where: { $0 == key })
                
            }
            
            ///
            self.orderedReactionKeys.append(key)
            
            ///
            self.reactions[key] = reaction
        }
    }
    
    ///
    public nonisolated func unregisterReaction_weakClosure
        (forKey key: String)
    -> @MainActor () -> () {
        
        return { [weak self] in
            
            ///
            guard let self else { return }
            
            ///
            if self.reactions.keys.contains(key) {
                
                ///
                self.orderedReactionKeys.removeAll(where: { $0 == key })
                
                ///
                self.reactions.removeValue(forKey: key)
            }
        }
    }
}
