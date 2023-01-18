//
//  map.swift
//  
//
//  Created by Jeremy Bannister on 10/30/22.
//

///
@_exported import MainActorValueModule_concrete

///
public extension MainActorValueAccessor {

    ///
    func map
        <NewValue>
        (_ transform: @escaping (Value)->NewValue)
    -> MappedMainActorValueAccessor<Value, NewValue> {

        ///
        MappedMainActorValueAccessor(
            base: self,
            transform: transform
        )
    }
}

///
public actor MappedMainActorValueAccessor
    <BaseValue,
     NewValue>:
        MainActorValueAccessor,
        ObservableObject {
    
    ///
    public typealias Value = NewValue
    
    ///
    public init
        (base: any MainActorValueAccessor<BaseValue>,
         transform: @escaping (BaseValue)->Value) {
        
        self.base = base
        self.transform = transform
    }
    
    ///
    private let base: any MainActorValueAccessor<BaseValue>
    
    ///
    private let transform: (BaseValue)->NewValue
    
    ///
    @MainActor
    public var value: Value {
        transform(base.value)
    }
    
    ///
    public nonisolated var didSet: AnyPublisher<NewValue, Never> {
        base
            .didSet
            .map { [transform] in transform($0) }
            .eraseToAnyPublisher()
    }
}
