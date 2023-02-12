//
//  Interface_SubscribableMainActorValue.swift
//  
//
//  Created by Jeremy Bannister on 2/12/23.
//

///
@_exported import MainActorValueModule_main_actor_value_accessor


///
public protocol
    Interface_SubscribableMainActorValue
        <Value>:
            MainActorValueAccessor {
    
    ///
    var willSet: any Interface_MainActorReactionManager<Void> { get }
    
    ///
    var didSet: any Interface_MainActorReactionManager<Value> { get }
}
