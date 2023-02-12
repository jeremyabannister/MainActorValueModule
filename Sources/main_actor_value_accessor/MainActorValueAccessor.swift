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
public protocol MainActorValueAccessor <Value>: HasRootObjectID {
    
    ///
    @MainActor
    var currentValue: Value { get }
    
    ///
    var willSet: any Interface_MainActorReactionManager<Void> { get }
    
    ///
    var didSet: any Interface_MainActorReactionManager<Value> { get }
    
    ///
    var didAccess: any Interface_MainActorReactionManager<Value> { get }
    
    ///
    associatedtype Value
}

///
public protocol HasRootObjectID {
    
    ///
    var rootObjectID: ObjectID { get }
}
