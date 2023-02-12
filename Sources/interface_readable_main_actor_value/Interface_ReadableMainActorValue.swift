//
//  Interface_ReadableMainActorValue.swift
//  
//
//  Created by Jeremy Bannister on 2/12/23.
//

///
@_exported import FoundationToolkit


///
public protocol Interface_ReadableMainActorValue <Value> {
    
    ///
    @MainActor
    var currentValue: Value { get }
    
    ///
    associatedtype Value
}
