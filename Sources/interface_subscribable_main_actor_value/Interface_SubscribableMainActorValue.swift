//
//  Interface_SubscribableMainActorValue.swift
//  
//
//  Created by Jeremy Bannister on 2/12/23.
//

///
@_exported import MainActorValueModule_interface_readable_main_actor_value


///
public protocol
    Interface_SubscribableMainActorValue
        <Value>:
            Interface_ReadableMainActorValue {
    
    ///
    var willSet: any Interface_MainActorReactionManager<Void> { get }
    
    ///
    var didSet: any Interface_MainActorReactionManager<Value> { get }
}
