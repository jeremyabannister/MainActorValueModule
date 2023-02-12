//
//  MainActorValueSource.swift
//  
//
//  Created by Jeremy Bannister on 2/10/23.
//

///
@_exported import MainActorValueModule_interface_readable_main_actor_value
@_exported import MainActorValueModule_main_actor_reaction_managers


///
public protocol
    MainActorValueSource
        <Value>:
            Interface_ReadableMainActorValue {
    
    ///
    @MainActor
    var currentValue: Value { get set }
    
    ///
    var objectID: ObjectID { get }
    
    ///
    var willSet: any Interface_MainActorReactionManager<Void> { get }
    
    ///
    var didSet: any Interface_MainActorReactionManager<Value> { get }
}

///
extension MainActorValueSource {
    
    ///
    public var didSet_Void: any Interface_MainActorReactionManager<Void> {
        self
            .didSet
            .map { _ in () }
    }
}
