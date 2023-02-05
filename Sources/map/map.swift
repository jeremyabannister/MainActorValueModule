//
//  map.swift
//  
//
//  Created by Jeremy Bannister on 10/30/22.
//

///
@_exported import MainActorValueModule_concrete

///
public extension MainActorValueAccessor_old {

    ///
    func map
        <NewValue>
        (_ transform: @escaping (Value)->NewValue)
    -> MappedMainActorValueAccessor_old<Value, NewValue> {

        ///
        MappedMainActorValueAccessor_old(
            base: self,
            transform: transform
        )
    }
}

///
public actor MappedMainActorValueAccessor_old
    <BaseValue,
     NewValue>:
        MainActorValueAccessor_old,
        ObservableObject {
    
    ///
    public typealias Value = NewValue
    
    ///
    public init
        (base: any MainActorValueAccessor_old<BaseValue>,
         transform: @escaping (BaseValue)->Value) {
        
        self.base = base
        self.transform = transform
    }
    
    ///
    private let base: any MainActorValueAccessor_old<BaseValue>
    
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
