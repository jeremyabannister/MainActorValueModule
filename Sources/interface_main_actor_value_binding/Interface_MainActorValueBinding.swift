//
//  Interface_MainActorValueBinding.swift
//  
//
//  Created by Jeremy Bannister on 9/14/23.
//

///
@_exported import MainActorValueModule_interface_readable_main_actor_value


///
@MainActor
public protocol Interface_MainActorValueBinding<Value>: Interface_ReadableMainActorValue {
    
    ///
    var currentValue: Value { get nonmutating set }
}
