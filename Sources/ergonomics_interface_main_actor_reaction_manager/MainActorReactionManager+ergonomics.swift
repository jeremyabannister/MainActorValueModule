//
//  MainActorReactionManager+ergonomics.swift
//  
//
//  Created by Jeremy Bannister on 2/8/23.
//

///
@_exported import Foundation
@_exported import MainActorValueModule_interface_main_actor_reaction_manager


///
extension Interface_MainActorReactionManager {
    
    ///
    @MainActor
    public func registerReaction(
        key: String,
        _ reaction: @escaping @MainActor (Event)->()
    ) {
        
        ///
        _registerReaction_weakClosure(key: key, reaction)()
    }
    
    ///
    @MainActor
    public func unregisterReaction(
        forKey key: String
    ) {
        
        ///
        _unregisterReaction_weakClosure(forKey: key)()
    }
}

///
extension Interface_MainActorReactionManager {
    
    ///
    @MainActor
    public func registerReactionPermanently(
        _ reaction: @escaping @MainActor (Event)->()
    ) {
        
        ///
        registerReaction(key: UUID().uuidString, reaction)
    }
}

///
extension Interface_MainActorReactionManager {
    
    ///
    @MainActor
    public func registerReaction(
        _ reaction: @escaping @MainActor (Event)->()
    ) -> ReactionRetainer {
        
        ///
        let key = UUID().uuidString
        
        ///
        registerReaction(key: key, reaction)
        
        ///
        let reactionRetainer =
            ReactionRetainer(
                leakTracker: leakTracker["ReactionRetainer(\(key))"],
                unregisterReaction: self._unregisterReaction_weakClosure(forKey: key)
            )
        
        ///
        return reactionRetainer
    }
}

///
@MainActor
public final class ReactionRetainer {
    
    ///
    fileprivate init(
        leakTracker: LeakTracker,
        unregisterReaction: @escaping @MainActor ()->()
    ) {
        
        ///
        self.unregisterReaction = unregisterReaction
        leakTracker.track(self)
    }
    
    ///
    private let unregisterReaction: @MainActor ()->()
    
    ///
    deinit {
        Task { @MainActor [unregisterReaction] in
            unregisterReaction()
        }
    }
}
