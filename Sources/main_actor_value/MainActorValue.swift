//
//  MainActorValue.swift
//  
//
//  Created by Jeremy Bannister on 2/12/23.
//

///
@_exported import MainActorValueModule_interface_readable_main_actor_value


///
public struct MainActorValue<Value>: Interface_ReadableMainActorValue {
    
    ///
    public init(_ fetchValue: @escaping @MainActor ()->Value) {
        self.fetchValue = fetchValue
    }
    
    ///
    private let fetchValue: @MainActor ()->Value
    
    ///
    @MainActor
    public var currentValue: Value {
        fetchValue()
    }
}
