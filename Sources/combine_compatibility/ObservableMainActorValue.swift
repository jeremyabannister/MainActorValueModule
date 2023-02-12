//
//  ObservableMainActorValue.swift
//  
//
//  Created by Jeremy Bannister on 2/5/23.
//

///
@_exported import Combine
@_exported import MainActorValueModule_main_actor_value
@_exported import MainActorValueModule_subscribable_main_actor_value_accessor


// MARK: - ObservableMainActorValue

///
extension MainActorValueAccessor {
    
    ///
    @MainActor
    public func asObservableMainActorValueAccessor () -> ObservableMainActorValueAccessor<Value> {
        
        ///
        let newObservableMainActorValueAccessor =
            ObservableMainActorValueAccessor(
                mainActorValue: self
            )
        
        ///
        return newObservableMainActorValueAccessor
    }
}

///
extension MainActorValue {
    
    ///
    @MainActor
    public func asObservableMainActorValue () -> ObservableMainActorValue<Value> {
        
        ///
        let newObservableMainActorValue =
            ObservableMainActorValue(
                mainActorValue: self
            )
        
        ///
        return newObservableMainActorValue
    }
}

///
public actor ObservableMainActorValueAccessor <Value>:
    MainActorValueAccessor,
    ObservableObject,
    ReferenceType {
    
    ///
    private let uuid = UUID()
    
    ///
    @MainActor
    fileprivate init
        (mainActorValue: some MainActorValueAccessor<Value>) {
        
        ///
        let objectWillChange = PassthroughSubject<Void, Never>()
        
        ///
        self.objectWillChange = objectWillChange.eraseToAnyPublisher()
        
        ///
        let subscribableValue = mainActorValue.madeSubscribable()
        
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
    private let subscribableValue: SubscribableMainActorValueAccessor<Value>
    
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
public actor ObservableMainActorValue <Value>:
    MainActorValueAccessor,
    ObservableObject,
    ReferenceType {
    
    ///
    @MainActor
    fileprivate init
        (mainActorValue: MainActorValue<Value>) {
        
        ///
        let objectWillChange = PassthroughSubject<Void, Never>()
        
        ///
        self.objectWillChange = objectWillChange.eraseToAnyPublisher()
        
        ///
        self.mainActorValue = mainActorValue
        
        ///
        mainActorValue
            .willSet
            .registerReaction(key: self.uuid.uuidString) { [objectWillChange] _ in
                objectWillChange.send()
            }
    }
    
    ///
    private let uuid = UUID()
    
    ///
    private let mainActorValue: MainActorValue<Value>
    
    ///
    deinit {
        Task { @MainActor [mainActorValue, uuid] in
            mainActorValue
                .willSet
                .unregisterReaction(forKey: uuid.uuidString)
        }
    }
    
    ///
    public nonisolated let objectWillChange: AnyPublisher<Void, Never>
    
    ///
    public nonisolated var rootObjectID: ObjectID {
        mainActorValue.rootObjectID
    }
    
    ///
    public nonisolated var willSet: any Interface_MainActorReactionManager<Void> {
        mainActorValue.willSet
    }
    
    ///
    public nonisolated var didSet: any Interface_MainActorReactionManager<Value> {
        mainActorValue.didSet
    }
    
    ///
    public nonisolated var didAccess: any Interface_MainActorReactionManager<Value> {
        mainActorValue.didAccess
    }
    
    ///
    @MainActor
    public var currentValue: Value {
        get { mainActorValue.currentValue }
        set { mainActorValue.currentValue = newValue }
    }
}
