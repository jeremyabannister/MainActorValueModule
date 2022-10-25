//
//  MainActorValueAccessor.swift
//  
//
//  Created by Jeremy Bannister on 10/20/22.
//

///
@_exported import FoundationToolkit

///
public protocol MainActorValueAccessor:
    ExpressionErgonomic,
    ObservableObject,
    ReferenceType {
    
    ///
    associatedtype Value
    
    ///
    @MainActor
    var value: Value { get }
}
