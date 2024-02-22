//
//  Interface_MainActorValueSourceAccessor.swift
//  
//
//  Created by Jeremy Bannister on 2/23/23.
//

///
public protocol Interface_MainActorValueSourceAccessor {
    
    ///
    @MainActor
    func _accessCurrentSources()
}
