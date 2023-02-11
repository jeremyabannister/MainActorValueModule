//
//  map.swift
//  
//
//  Created by Jeremy Bannister on 10/30/22.
//

///
@_exported import MainActorValueModule_main_actor_value
@_exported import MainActorValueModule_mapped_reaction_hub


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
