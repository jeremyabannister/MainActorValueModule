//
//  Interface_MainActorReactionManager.swift
//  
//
//  Created by Jeremy Bannister on 2/12/23.
//

///
@_exported import LeakTracker_module


///
public protocol Interface_MainActorReactionManager <Event> {
    
    ///
    func _registerReaction_weakClosure(
        key: String,
        _ reaction: @escaping @MainActor (Event)->()
    ) -> @MainActor ()->()
    
    ///
    func _unregisterReaction_weakClosure(
        forKey key: String
    ) -> @MainActor ()->()
    
    ///
    var leakTracker: LeakTracker { get }
    
    ///
    associatedtype Event
}
