//
//  Interface_MainActorValueSource.swift
//  
//
//  Created by Jeremy Bannister on 2/12/23.
//

///
internal protocol Interface_MainActorValueSource: Interface_MainActorValueBinding,
                                                  Interface_SubscribableMainActorValue {
    
    /// We need didSet_erased internally because for older OS versions we don't have "runtime support for parameterized protocol types".
    var didSet_erased: any Interface_MainActorReactionManager { get }
}
