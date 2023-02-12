//
//  MainActorReactionHub.swift
//  
//
//  Created by Jeremy Bannister on 2/10/23.
//

///
@_exported import MainActorValueModule_main_actor_value_accessor

///
public actor MainActorReactionHub <Event>: MainActorReactionManager {
    
    ///
    public init () { }
    
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
    public nonisolated func registerReaction_weakClosure
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
    public nonisolated func unregisterReaction_weakClosure
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
