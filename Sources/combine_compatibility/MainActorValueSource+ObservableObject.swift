//
//  MainActorValueSource+ObservableObject.swift
//  
//
//  Created by Jeremy Bannister on 9/15/23.
//

///
extension MainActorValueSource: ObservableObject {
    
    ///
    public nonisolated var objectWillChange: MainActorReactionManager<Void> {
        _willSet
    }
}
