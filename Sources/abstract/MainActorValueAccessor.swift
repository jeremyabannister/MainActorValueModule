//
//  MainActorValueAccessor.swift
//  
//
//  Created by Jeremy Bannister on 10/20/22.
//

///
@_exported import Combine
@_exported import FoundationToolkit


// MARK: - new

///
public protocol MainActorValueAccessor_new <Value>: HasRootObjectID {
    
    ///
    @MainActor
    var currentValue: Value { get }
    
    ///
    var willSet: any MainActorReactionManager<Value> { get }
    
    ///
    var didSet: any MainActorReactionManager<Value> { get }
    
    ///
    associatedtype Value
}

///
public protocol HasRootObjectID {
    
    ///
    var rootObjectID: ObjectID { get }
}

///
public protocol MainActorReactionManager <Event> {
    
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

///
extension MainActorReactionManager {
    
    ///
    @MainActor
    func registerReaction
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


// MARK: - old

///
public protocol MainActorValueAccessor_old <Value>:
    ExpressionErgonomic {
    
    ///
    @MainActor
    var value: Value { get }
    
    ///
    var didSet: AnyPublisher<Value, Never> { get }
    
    ///
    associatedtype Value
}

///
extension MainActorValueAccessor_old {
    
    ///
    @MainActor
    public var currentValue: Value {
        value
    }
}
