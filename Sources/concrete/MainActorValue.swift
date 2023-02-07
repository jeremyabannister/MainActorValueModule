//
//  MainActorValue.swift
//  
//
//  Created by Jeremy Bannister on 10/20/22.
//

///
@_exported import MainActorValueModule_abstract


// MARK: - new

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


// MARK: - old

///
@propertyWrapper
public final class MainActorValue_old
    <Value>:
        MainActorValueAccessor_old,
        ObservableObject,
        ReferenceType {
    
    ///
    public nonisolated var projectedValue: MainActorValue_old<Value> {
        self
    }
    
    ///
    @MainActor
    public var wrappedValue: Value {
        get { valueAccess.get() }
        set {
            objectWillChange.send()
            valueAccess.set(newValue)
        }
    }
    
    ///
    public convenience init (wrappedValue: Value) {
        
        ///
        self.init(
            wrappedValue: wrappedValue,
            didSet: { _ in }
        )
    }
    
    ///
    public convenience init
        (wrappedValue: Value,
         didSet: @escaping @MainActor (Value)->()) {
        
        ///
        self.init(
            wrappedValue: .initialized(wrappedValue),
            didSet: didSet
        )
    }
    
    ///
    public convenience init
        (uninitializedValue: @escaping @MainActor ()->Value,
         didSet: @escaping @MainActor (Value)->()) {
        
        ///
        self.init(
            wrappedValue: .uninitialized(uninitializedValue),
            didSet: didSet
        )
    }
    
    ///
    private convenience init
        (wrappedValue: ValueAccess.Storage,
         didSet: @escaping @MainActor (Value)->()) {
        
        ///
        let didSetSubject = PassthroughSubject<Value, Never>()
        
        ///
        self.init(
            valueAccess: .stored(
                wrappedValue,
                didSet: {
                    didSet($0)
                    didSetSubject.send($0)
                }
            ),
            objectWillChangePublisher: .init(),
            didSetPublisher: didSetSubject.eraseToAnyPublisher()
        )
    }
    
    ///
    private nonisolated init
        (valueAccess: ValueAccess,
         objectWillChangePublisher: ObservableObjectPublisher,
         didSetPublisher: AnyPublisher<Value, Never>) {
        
        self.valueAccess = valueAccess
        self.objectWillChange = objectWillChangePublisher
        self.didSetPublisher = didSetPublisher
    }
    
    ///
    private nonisolated let didSetPublisher: AnyPublisher<Value, Never>
    
    ///
    public nonisolated let objectWillChange: ObservableObjectPublisher
    
    ///
    @MainActor
    private var valueAccess: ValueAccess
    
    ///
    private enum ValueAccess {
        case stored (Storage, didSet: @MainActor (Value)->())
        case computed (getter: @MainActor ()->Value,
                       setter: @MainActor (Value)->())
        
        enum Storage {
            case initialized (Value)
            case uninitialized (@MainActor ()->Value)
        }
        
        ///
        @MainActor
        mutating func get () -> Value {
            switch self {
            case .stored (let storage, let didSet):
                switch storage {
                case .initialized (let value):
                    return value
                case .uninitialized (let valueGenerator):
                    let value = valueGenerator()
                    self = .stored(.initialized(value), didSet: didSet)
                    return value
                }
            case .computed (let getter, _):
                return getter()
            }
        }
        
        ///
        @MainActor
        mutating func set (_ newValue: Value) {
            switch self {
            case .stored (_, let didSet):
                self = .stored(.initialized(newValue), didSet: didSet)
                didSet(newValue)
                
            case .computed(_, let setter):
                setter(newValue)
            }
        }
    }
}

///
extension MainActorValue_old {
    
    ///
    @MainActor
    public var currentValue: Value {
        get { value }
        set { value = newValue }
    }
    
    ///
    public convenience init (initialValue: Value) {
        self.init(wrappedValue: initialValue)
    }
}

///
public extension MainActorValue_old {
    
    ///
    @MainActor
    var value: Value {
        get { wrappedValue }
        set { wrappedValue = newValue }
    }
    
    ///
    @MainActor
    func setValue (to newValue: Value) {
        wrappedValue = newValue
    }
    
    ///
    @MainActor
    func mutateValue (using mutation: (inout Value)->()) {
        mutation(&wrappedValue)
    }
    
    ///
    nonisolated var didSet: AnyPublisher<Value, Never> {
        didSetPublisher
    }
}
