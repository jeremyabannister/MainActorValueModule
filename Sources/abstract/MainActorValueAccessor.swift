//
//  MainActorValueAccessor.swift
//  
//
//  Created by Jeremy Bannister on 10/20/22.
//

///
@_exported import Combine
@_exported import FoundationToolkit

///
public protocol MainActorValueAccessor <Value>:
    ExpressionErgonomic {
    
    ///
    @MainActor
    var value: Value { get }
    
    ///
    var didSet: AnyPublisher<Value, Never> { get }
    
    ///
    associatedtype Value
}
