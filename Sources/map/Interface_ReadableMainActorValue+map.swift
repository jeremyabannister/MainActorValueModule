//
//  Interface_ReadableMainActorValue+map.swift
//
//
//  Created by Jeremy Bannister on 10/30/22.
//

///
extension Interface_ReadableMainActorValue {
    
    ///
    public func map<
        NewValue
    >(
        _ transform: @escaping @MainActor (Value)->NewValue
    ) -> MainActorValue<NewValue> {
        
        ///
        MainActorValue { [self] in
            transform(currentValue)
        }
    }
}
