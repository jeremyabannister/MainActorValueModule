//
//  MappedMainActorReactionManager.swift
//  
//
//  Created by Jeremy Bannister on 2/11/23.
//

///
@_exported import MainActorValueModule_interface_main_actor_reaction_manager


///
extension Interface_MainActorReactionManager {
    
    ///
    public func map
        <NewEvent>
        (_ transform: @escaping @MainActor (Event)->NewEvent)
    -> MappedMainActorReactionManager<Event, NewEvent> {
        
        ///
        .init(
            base: self,
            transform: transform
        )
    }
}


///
public struct MappedMainActorReactionManager
    <UpstreamEvent,
     Event>:
        Interface_MainActorReactionManager {
    
    ///
    fileprivate init
        (base: some Interface_MainActorReactionManager<UpstreamEvent>,
         transform: @escaping @MainActor (UpstreamEvent)->Event) {
        
        self.base = base
        self.transform = transform
    }
    
    ///
    private let base: any Interface_MainActorReactionManager<UpstreamEvent>
    
    ///
    private let transform: @MainActor (UpstreamEvent)->Event
    
    ///
    public func registerReaction_weakClosure
        (key: String,
         _ reaction: @escaping @MainActor (Event)->())
    -> @MainActor ()->() {
        
        ///
        base.registerReaction_weakClosure(key: key) {
            reaction(transform($0))
        }
    }
    
    ///
    public func unregisterReaction_weakClosure
        (forKey key: String)
    -> @MainActor ()->() {
        
        ///
        base.unregisterReaction_weakClosure(forKey: key)
    }
}
