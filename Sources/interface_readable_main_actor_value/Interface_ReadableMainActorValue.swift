//
//  Interface_ReadableMainActorValue.swift
//  
//
//  Created by Jeremy Bannister on 2/12/23.
//

///
@_exported import FoundationToolkit
@_exported import MainActorValueModule_interface_main_actor_reaction_manager


///
public protocol Interface_ReadableMainActorValue <Value> {
    
    ///
    @MainActor
    var currentValue: Value { get }
    
    ///
    associatedtype Value
}
