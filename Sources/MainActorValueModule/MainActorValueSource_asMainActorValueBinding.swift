//
//  MainActorValueSource_asMainActorValueBinding.swift
//
//
//  Created by Jeremy Bannister on 6/17/24.
//

///
extension MainActorValueSource {
    
    ///
    public func getBinding() -> SubscribableMainActorValueBinding<Value> {
        .init(
            subscribableValue: self,
            setValue: { self.currentValue = $0 }
        )
    }
}

///
extension MainActorValueSource {
    
    ///
    public var asMainActorValueBinding: MainActorValueBinding<Value> {
        .init(
            get: { self.currentValue },
            set: { self.currentValue = $0 }
        )
    }
}
