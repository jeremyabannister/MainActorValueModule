//
//  map.swift
//  
//
//  Created by Jeremy Bannister on 10/30/22.
//

///
@_exported import MainActorValueModule_concrete


///
extension MainActorValueAccessor {
    
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
public struct MappedMainActorValue <Value>: MainActorValueAccessor {
    
    ///
    fileprivate init
        <Base: MainActorValueAccessor>
        (base: Base,
         transform: @escaping @MainActor (Base.Value)->Value) {
        
        ///
        self._fetchCurrentValue = { transform(base.currentValue) }
        self.willSet = base.willSet
        self.didSet = MappedReactionHub(base: base.didSet, transform: transform)
        self.didAccess = MappedReactionHub(base: base.didAccess, transform: transform)
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
    public let willSet: any MainActorReactionManager<Void>
    public let didSet: any MainActorReactionManager<Value>
    public let didAccess: any MainActorReactionManager<Value>
    
    ///
    public let rootObjectID: ObjectID
}

///
fileprivate struct MappedReactionHub <UpstreamEvent,Event>: MainActorReactionManager {
    
    ///
    init
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
    func registerReaction_weakClosure
        (key: String,
         _ reaction: @escaping @MainActor (Event)->())
    -> @MainActor ()->() {
        
        ///
        base.registerReaction_weakClosure(key: key) {
            reaction(transform($0))
        }
    }
    
    ///
    func unregisterReaction_weakClosure
        (forKey key: String)
    -> @MainActor ()->() {
        
        ///
        base.unregisterReaction_weakClosure(forKey: key)
    }
}
