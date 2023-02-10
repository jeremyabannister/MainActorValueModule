//
//  MainActorValueSource.swift
//  
//
//  Created by Jeremy Bannister on 2/10/23.
//

///
@_exported import MainActorValueModule_main_actor_value_accessor


///
public protocol MainActorValueSource <Value>: MainActorValueAccessor {
    
    ///
    @MainActor
    var currentValue: Value { get set }
    
    ///
    var objectID: ObjectID { get }
    
    ///
    var willSet: any MainActorReactionManager<Void> { get }
    
    ///
    var didSet: any MainActorReactionManager<Value> { get }
    
    ///
    var didAccess: any MainActorReactionManager<Value> { get }
}
