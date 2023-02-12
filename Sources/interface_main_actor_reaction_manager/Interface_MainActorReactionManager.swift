//
//  Interface_MainActorReactionManager.swift
//  
//
//  Created by Jeremy Bannister on 2/12/23.
//

///
public protocol Interface_MainActorReactionManager <Event> {
    
    ///
    func registerReaction_weakClosure
        (key: String,
         _ reaction: @escaping @MainActor (Event)->())
    -> @MainActor ()->()
    
    ///
    func unregisterReaction_weakClosure
        (forKey key: String)
    -> @MainActor ()->()
    
    ///
    associatedtype Event
}
