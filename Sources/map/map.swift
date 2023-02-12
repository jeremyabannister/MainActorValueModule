//
//  map.swift
//  
//
//  Created by Jeremy Bannister on 10/30/22.
//

///
@_exported import MainActorValueModule_main_actor_value


///
extension Interface_ReadableMainActorValue {
    
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
public struct
    MappedMainActorValue
        <Value>:
            Interface_ReadableMainActorValue {
    
    ///
    fileprivate init
        <Base: Interface_ReadableMainActorValue>
        (base: Base,
         transform: @escaping @MainActor (Base.Value)->Value) {
        
        ///
        self._fetchCurrentValue = { transform(base.currentValue) }
    }
    
    ///
    @MainActor
    public var currentValue: Value {
        _fetchCurrentValue()
    }
    
    ///
    private let _fetchCurrentValue: @MainActor ()->Value
}
