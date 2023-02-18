//
//  ObservableMainActorValue.swift
//  
//
//  Created by Jeremy Bannister on 2/5/23.
//

///
@_exported import Combine
@_exported import MainActorValueModule_main_actor_value_source


// MARK: - ObservableMainActorValue

///
extension Interface_ReadableMainActorValue {
    
    ///
    @MainActor
    public func asObservableMainActorValue () -> ObservableMainActorValue<Value> {
        
        ///
        let newObservableMainActorValue =
            ObservableMainActorValue(
                readableValue: self
            )
        
        ///
        return newObservableMainActorValue
    }
}

///
extension MainActorValueSource {
    
    ///
    @MainActor
    public func asObservableMainActorValueSource () -> ObservableMainActorValueSource<Value> {
        
        ///
        let newObservableMainActorValueSource =
            ObservableMainActorValueSource(
                source: self
            )
        
        ///
        return newObservableMainActorValueSource
    }
}

///
public actor
    ObservableMainActorValue
        <Value>:
            Interface_SubscribableMainActorValue,
            ObservableObject,
            ReferenceType {
    
    ///
    private let uuid = UUID()
    
    ///
    @MainActor
    fileprivate init
        (readableValue: some Interface_ReadableMainActorValue<Value>) {
        
        ///
        let objectWillChange = PassthroughSubject<Void, Never>()
        
        ///
        self.objectWillChange = objectWillChange.eraseToAnyPublisher()
        
        ///
        let subscribableValue = readableValue.madeSubscribable()
        
        ///
        self.subscribableValue = subscribableValue
        
        ///
        subscribableValue
            .willSet
            .registerReaction(key: self.uuid.uuidString) { [objectWillChange] _ in
                objectWillChange.send()
            }
    }
    
    ///
    private let subscribableValue: SubscribableMainActorValue<Value>
    
    ///
    deinit {
        Task { @MainActor [subscribableValue, uuid] in
            subscribableValue
                .willSet
                .unregisterReaction(forKey: uuid.uuidString)
        }
    }
    
    ///
    public nonisolated let objectWillChange: AnyPublisher<Void, Never>
    
    ///
    public nonisolated var rootObjectID: ObjectID {
        fatalError()
    }
    
    ///
    public nonisolated var willSet: any Interface_MainActorReactionManager<Void> {
        subscribableValue.willSet
    }
    
    ///
    public nonisolated var didSet: any Interface_MainActorReactionManager<Value> {
        subscribableValue.didSet
    }
    
    ///
    public nonisolated var didAccess: any Interface_MainActorReactionManager<Value> {
        fatalError()
    }
    
    ///
    @MainActor
    public var currentValue: Value {
        subscribableValue.currentValue
    }
}

///
public actor
    ObservableMainActorValueSource
        <Value>:
            Interface_SubscribableMainActorValue,
            ObservableObject,
            ReferenceType {
    
    ///
    @MainActor
    fileprivate init
        (source: MainActorValueSource<Value>) {
        
        ///
        let objectWillChange = PassthroughSubject<Void, Never>()
        
        ///
        self.objectWillChange = objectWillChange.eraseToAnyPublisher()
        
        ///
        self.source = source
        
        ///
        source
            .willSet
            .registerReaction(key: self.uuid.uuidString) { [objectWillChange] _ in
                objectWillChange.send()
            }
    }
    
    ///
    private let uuid = UUID()
    
    ///
    private let source: MainActorValueSource<Value>
    
    ///
    deinit {
        Task { @MainActor [source, uuid] in
            source
                .willSet
                .unregisterReaction(forKey: uuid.uuidString)
        }
    }
    
    ///
    public nonisolated let objectWillChange: AnyPublisher<Void, Never>
    
    ///
    public nonisolated var willSet: any Interface_MainActorReactionManager<Void> {
        source.willSet
    }
    
    ///
    public nonisolated var didSet: any Interface_MainActorReactionManager<Value> {
        source.didSet
    }
    
    ///
    @MainActor
    public var currentValue: Value {
        get { source.currentValue }
        set { source.currentValue = newValue }
    }
}
