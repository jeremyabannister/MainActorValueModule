//
//  map.swift
//  
//
//  Created by Jeremy Bannister on 10/30/22.
//

///
@_exported import MainActorValueModule_concrete


// MARK: - new

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


// MARK: - old

///
public extension MainActorValueAccessor_old {

    ///
    func map
        <NewValue>
        (_ transform: @escaping (Value)->NewValue)
    -> MappedMainActorValueAccessor_old<Value, NewValue> {

        ///
        MappedMainActorValueAccessor_old(
            base: self,
            transform: transform
        )
    }
}

///
public actor MappedMainActorValueAccessor_old
    <BaseValue,
     NewValue>:
        MainActorValueAccessor_old,
        ObservableObject {
    
    ///
    public typealias Value = NewValue
    
    ///
    public init
        (base: any MainActorValueAccessor_old<BaseValue>,
         transform: @escaping (BaseValue)->Value) {
        
        self.base = base
        self.transform = transform
    }
    
    ///
    private let base: any MainActorValueAccessor_old<BaseValue>
    
    ///
    private let transform: (BaseValue)->NewValue
    
    ///
    @MainActor
    public var value: Value {
        transform(base.value)
    }
    
    ///
    public nonisolated var didSet: AnyPublisher<NewValue, Never> {
        base
            .didSet
            .map { [transform] in transform($0) }
            .eraseToAnyPublisher()
    }
}
