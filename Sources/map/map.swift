//
//  map.swift
//  
//
//  Created by Jeremy Bannister on 10/30/22.
//

///
@_exported import MainActorValueModule_main_actor_value


///
extension Interface_ReadableMainActorValue {
    
    ///
    public func map
        <NewValue>
        (_ transform: @escaping @MainActor (Value)->NewValue)
    -> MainActorValue<NewValue> {
        
        ///
        MainActorValue { [self] in
            transform(currentValue)
        }
    }
}
