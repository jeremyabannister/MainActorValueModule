//
//  MainActorReactionManager.swift
//  
//
//  Created by Jeremy Bannister on 2/10/23.
//

///
@_exported import MainActorValueModule_interface_main_actor_reaction_manager


///
public actor MainActorReactionManager <Event>: Interface_MainActorReactionManager {
    
    ///
    @MainActor
    public init (leakTracker: LeakTracker) {
        
        ///
        self.leakTracker = leakTracker
        
        ///
        leakTracker.track(self)
    }
    
    ///
    public init
        (leakTracker: LeakTracker,
         nonisolatedOverload: Void) {
        
        ///
        self.leakTracker = leakTracker
        
        ///
        Task { @MainActor in
            leakTracker.track(self)
        }
    }
    
    ///
    public let leakTracker: LeakTracker
    
    ///
    @MainActor
    private var reactions: [String: @MainActor (Event)->()] = [:]
    
    ///
    @MainActor
    private var orderedReactionKeys: [String] = []
    
    ///
    @MainActor
    public var orderedReactions: [@MainActor (Event)->()] {
        orderedReactionKeys
            .compactMap { reactions[$0] }
    }
    
    ///
    public nonisolated func _registerReaction_weakClosure
        (key: String,
         _ reaction: @escaping @MainActor (Event)->())
    -> @MainActor ()->() {
        
        ///
        return { [weak self] in
            
            ///
            guard let self else { return }
            
            ///
            if self.reactions.keys.contains(key) {
                
                ///
                self.orderedReactionKeys.removeAll(where: { $0 == key })
            }
            
            ///
            self.orderedReactionKeys.append(key)
            
            ///
            self.reactions[key] = reaction
        }
    }
    
    ///
    public nonisolated func _unregisterReaction_weakClosure
        (forKey key: String)
    -> @MainActor () -> () {
        
        ///
        return { [weak self] in
            
            ///
            guard let self else { return }
            
            ///
            if self.reactions.keys.contains(key) {
                
                ///
                self.orderedReactionKeys.removeAll(where: { $0 == key })
                
                ///
                self.reactions.removeValue(forKey: key)
            }
        }
    }
}
