//
//  _exported_imports.swift
//  
//
//  Created by Jeremy Bannister on 10/25/22.
//

///
@_exported import MainActorValueModule_concrete
@_exported import MainActorValueModule_map

///
#if false
public typealias MainActorValue = MainActorValue_new
public typealias MainActorValueAccessor = MainActorValueAccessor_new
#else
public typealias MainActorValue = MainActorValue_old
public typealias MainActorValueAccessor = MainActorValueAccessor_old
#endif



///
extension MainActorValueAccessor_new {
    
    ///
    public func map
        <NewValue>
        (_ transform: @escaping @MainActor (Value)->NewValue)
    -> MappedMainActorValue<NewValue> {
        
        ///
        MappedMainActorValue(
            base: self,
            transform: transform
        )
    }
}

///
public struct MappedMainActorValue <Value>: MainActorValueAccessor_new {
    
    ///
    fileprivate init
        <Base: MainActorValueAccessor_new>
        (base: Base,
         transform: @escaping @MainActor (Base.Value)->Value) {
        
        ///
        self._fetchCurrentValue = { transform(base.currentValue) }
        self.willSet = MappedReactionHub(base: base.willSet, transform: transform)
        self.didSet = MappedReactionHub(base: base.didSet, transform: transform)
        self.rootObjectID = base.rootObjectID
    }
    
    ///
    @MainActor
    public var currentValue: Value {
        _fetchCurrentValue()
    }
    
    ///
    private let _fetchCurrentValue: @MainActor ()->Value
    
    ///
    public let willSet: any MainActorReactionManager<Value>
    public let didSet: any MainActorReactionManager<Value>
    
    ///
    public let rootObjectID: ObjectID
}

///
public struct MappedReactionHub <UpstreamEvent,Event>: MainActorReactionManager {
    
    ///
    internal init
        (base: some MainActorReactionManager<UpstreamEvent>,
         transform: @escaping @MainActor (UpstreamEvent)->Event) {
        
        self.base = base
        self.transform = transform
    }
    
    ///
    private let base: any MainActorReactionManager<UpstreamEvent>
    
    ///
    private let transform: @MainActor (UpstreamEvent)->Event
    
    ///
    public func registerReaction_weakClosure
        (key: String,
         _ reaction: @escaping @MainActor (Event)->())
    -> @MainActor ()->() {
        
        ///
        base.registerReaction_weakClosure(key: key) {
            reaction(transform($0))
        }
    }
    
    ///
    public func unregisterReaction_weakClosure
        (forKey key: String)
    -> @MainActor ()->() {
        
        ///
        base.unregisterReaction_weakClosure(forKey: key)
    }
}

///
public actor MainActorValue_new <Value>:
    MainActorValueAccessor_new,
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
extension MainActorValue_new {
    
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
extension MainActorValue_new {
    
    ///
    @available(*, deprecated, message: "Use `currentValue` instead, this property will be removed soon.")
    @MainActor
    public var value: Value {
        get { currentValue }
        set { currentValue = newValue }
    }
}

///
extension MainActorValue_new {
    
    ///
    @available(*, deprecated, message: "Use `init(uninitializedValue:)` and add your didSet reaction manually. This initializer will be removed soon.")
    public init
        (uninitializedValue: @escaping @MainActor ()->Value,
         didSet: @escaping @MainActor (Value)->()) {
        
        ///
        self.init(uninitializedValue: uninitializedValue)
        
        ///
        Task { @MainActor in
            self
                .didSet
                .registerReaction(didSet)
        }
    }
}

///
public protocol MainActorValueAccessor_new <Value>: HasRootObjectID {
    
    ///
    @MainActor
    var currentValue: Value { get }
    
    ///
    var willSet: any MainActorReactionManager<Value> { get }
    
    ///
    var didSet: any MainActorReactionManager<Value> { get }
    
    ///
    associatedtype Value
}

///
public protocol HasRootObjectID {
    
    ///
    var rootObjectID: ObjectID { get }
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

///
extension MainActorReactionManager {
    
    ///
    @MainActor
    public func registerReactionPermanently
        (_ reaction: @escaping @MainActor (Event)->()) {
        
        ///
        registerReaction(key: UUID().uuidString, reaction)
    }
}

///
extension MainActorReactionManager {
    
    ///
    @MainActor
    public func registerReaction
        (_ reaction: @escaping @MainActor (Event)->())
    -> ReactionRetainer {
        
        ///
        let key = UUID().uuidString
        
        ///
        registerReaction(key: key, reaction)
        
        ///
        let reactionRetainer =
            ReactionRetainer(
                unregisterReaction: self.unregisterReaction_weakClosure(forKey: key)
            )
        
        ///
        return reactionRetainer
    }
}

///
public actor ReactionRetainer {
    fileprivate init (unregisterReaction: @escaping @MainActor ()->()) {
        self.unregisterReaction = unregisterReaction
    }
    private let unregisterReaction: @MainActor ()->()
    deinit {
        Task { @MainActor [unregisterReaction] in
            unregisterReaction()
        }
    }
}

///
extension MainActorReactionManager {
    
    ///
    @MainActor
    func registerReaction
        (key: String,
         _ reaction: @escaping @MainActor (Event)->()) {
        
        ///
        registerReaction_weakClosure(key: key, reaction)()
    }
    
    ///
    @MainActor
    public func unregisterReaction
        (forKey key: String) {
        
        ///
        unregisterReaction_weakClosure(forKey: key)()
    }
}

///
public protocol MainActorReactionManager <Event> {
    
    ///
    func registerReaction_weakClosure
        (key: String,
         _ reaction: @escaping @MainActor (Event)->())
    -> @MainActor ()->()
    
    ///
    func unregisterReaction_weakClosure
        (forKey key: String)
    -> @MainActor ()->()
    
    ///
    associatedtype Event
}
