//
//  MainActorReactionManager+ergonomics.swift
//  
//
//  Created by Jeremy Bannister on 2/8/23.
//

///
@_exported import MainActorValueModule_main_actor_value_accessor

///
extension MainActorReactionManager {
    
    ///
    @MainActor
    public func registerReaction
        (key: String,
         _ reaction: @escaping @MainActor (Event)->()) {
        
        ///
        registerReaction_weakClosure(key: key, reaction)()
    }
    
    ///
    @MainActor
    public func unregisterReaction
        (forKey key: String) {
        
        ///
        unregisterReaction_weakClosure(forKey: key)()
    }
}

///
extension MainActorReactionManager {
    
    ///
    @MainActor
    public func registerReactionPermanently
        (_ reaction: @escaping @MainActor (Event)->()) {
        
        ///
        registerReaction(key: UUID().uuidString, reaction)
    }
}

///
extension MainActorReactionManager {
    
    ///
    @MainActor
    public func registerReaction
        (_ reaction: @escaping @MainActor (Event)->())
    -> ReactionRetainer {
        
        ///
        let key = UUID().uuidString
        
        ///
        registerReaction(key: key, reaction)
        
        ///
        let reactionRetainer =
            ReactionRetainer(
                unregisterReaction: self.unregisterReaction_weakClosure(forKey: key)
            )
        
        ///
        return reactionRetainer
    }
}

///
public actor ReactionRetainer {
    fileprivate init (unregisterReaction: @escaping @MainActor ()->()) {
        self.unregisterReaction = unregisterReaction
    }
    private let unregisterReaction: @MainActor ()->()
    deinit {
        Task { @MainActor [unregisterReaction] in
            unregisterReaction()
        }
    }
}
