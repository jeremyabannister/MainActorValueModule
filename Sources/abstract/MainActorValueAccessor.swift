//
//  MainActorValueAccessor.swift
//  
//
//  Created by Jeremy Bannister on 10/20/22.
//

///
@_exported import FoundationToolkit

///
public protocol MainActorValueAccessor <Value>: HasRootObjectID {
    
    ///
    @MainActor
    var currentValue: Value { get }
    
    ///
    var willSet: any MainActorReactionManager<Void> { get }
    
    ///
    var didSet: any MainActorReactionManager<Value> { get }
    
    ///
    var didAccess: any MainActorReactionManager<Value> { get }
    
    ///
    associatedtype Value
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
public protocol HasRootObjectID {
    
    ///
    var rootObjectID: ObjectID { get }
}
