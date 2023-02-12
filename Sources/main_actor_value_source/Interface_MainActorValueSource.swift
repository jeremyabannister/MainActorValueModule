//
//  Interface_MainActorValueSource.swift
//  
//
//  Created by Jeremy Bannister on 2/12/23.
//

///
internal protocol
    Interface_MainActorValueSource:
        Interface_SubscribableMainActorValue {
    
    ///
    @MainActor
    var currentValue: Value { get set }
}
