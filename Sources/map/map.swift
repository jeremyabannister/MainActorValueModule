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
    -> MappedMainActorValue<NewValue> {
        
        ///
        .init(
            baseValueAccessor: self,
            transform: transform
        )
    }
}

///
@MainActor
public final class MappedMainActorValue
    <Value>:
        MainActorValueAccessor {
    
    ///
    public let objectWillChange = ObservableObjectPublisher()
    
    ///
    private var connection: Any? = nil
    
    ///
    private let computeValue: @MainActor ()->Value
    
    ///
    public var value: Value { computeValue() }
    
    ///
    nonisolated init
        (_ computeValue: @escaping @MainActor ()->Value) {
        
        ///
        self.computeValue = computeValue
    }
    
    ///
    nonisolated init
        <BaseValueAccessor: MainActorValueAccessor>
        (baseValueAccessor: BaseValueAccessor,
         transform: @escaping (BaseValueAccessor.Value)->Value) {
        
        self.computeValue = { transform(baseValueAccessor.value) }
        self.connection =
            baseValueAccessor
                .objectWillChange
                .sink(receiveValue: { [objectWillChange] _ in
                    objectWillChange.send()
                })
    }
    
    ///
    @available(*, deprecated, message: "Not implemented - fatalError()")
    public nonisolated var didSet: AnyPublisher<Value, Never> {
        fatalError()
    }
}
