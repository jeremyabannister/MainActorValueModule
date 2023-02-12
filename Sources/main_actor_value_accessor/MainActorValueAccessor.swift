//
//  MainActorValueAccessor.swift
//  
//
//  Created by Jeremy Bannister on 10/20/22.
//

///
@_exported import FoundationToolkit
@_exported import MainActorValueModule_interface_main_actor_reaction_manager

///
public protocol MainActorValueAccessor <Value> {
    
    ///
    @MainActor
    var currentValue: Value { get }
    
    ///
    associatedtype Value
}
