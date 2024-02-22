//
//  Interface_ReadableMainActorValue.swift
//  
//
//  Created by Jeremy Bannister on 2/12/23.
//

///
@_exported import MainActorValueModule_interface_main_actor_value_source_accessor


///
public protocol Interface_ReadableMainActorValue<Value>: Interface_MainActorValueSourceAccessor {
    
    ///
    @MainActor
    var currentValue: Value { get }
    
    ///
    associatedtype Value
}

///
extension Interface_ReadableMainActorValue {
    
    ///
    @MainActor
    public func _accessCurrentSources() {
        _ = self.currentValue
    }
}
