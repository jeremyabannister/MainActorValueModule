//
//  ObservableMainActorValue.swift
//  
//
//  Created by Jeremy Bannister on 2/5/23.
//

///
@_exported import Combine
@_exported import MainActorValueModule_concrete
@_exported import MainActorValueModule_ergonomics


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
    @MainActor
    fileprivate init
        (mainActorValue: some MainActorValueAccessor<Value>) {
        
        ///
        self.objectWillChange = properlyConfiguredObjectWillChange(for: mainActorValue)
        self.mainActorValue = mainActorValue
    }
    
    ///
    public nonisolated let objectWillChange: AnyPublisher<Void, Never>
    
    ///
    private let mainActorValue: any MainActorValueAccessor<Value>
    
    ///
    public nonisolated var rootObjectID: ObjectID {
        mainActorValue.rootObjectID
    }
    
    ///
    public nonisolated var willSet: any MainActorReactionManager<Value> {
        mainActorValue.willSet
    }
    
    ///
    public nonisolated var didSet: any MainActorReactionManager<Value> {
        mainActorValue.didSet
    }
    
    ///
    @MainActor
    public var currentValue: Value {
        mainActorValue.currentValue
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
        self.objectWillChange = properlyConfiguredObjectWillChange(for: mainActorValue)
        self.mainActorValue = mainActorValue
    }
    
    ///
    public nonisolated let objectWillChange: AnyPublisher<Void, Never>
    
    ///
    private let mainActorValue: MainActorValue<Value>
    
    ///
    public nonisolated var rootObjectID: ObjectID {
        mainActorValue.rootObjectID
    }
    
    ///
    public nonisolated var willSet: any MainActorReactionManager<Value> {
        mainActorValue.willSet
    }
    
    ///
    public nonisolated var didSet: any MainActorReactionManager<Value> {
        mainActorValue.didSet
    }
    
    ///
    @MainActor
    public var currentValue: Value {
        get { mainActorValue.currentValue }
        set { mainActorValue.currentValue = newValue }
    }
    
    ///
    @MainActor
    public var value: Value {
        get { currentValue }
        set { currentValue = newValue }
    }
}

///
@MainActor
fileprivate func properlyConfiguredObjectWillChange
    (for valueAccessor: some MainActorValueAccessor)
-> AnyPublisher<Void, Never> {
    
    ///
    if let preexisting = MainActorValueAccessor_objectWillChange.currentValue[valueAccessor.rootObjectID] {
        
        ///
        return preexisting.objectWillChange
        
    } else {
        
        ///
        let subject = PassthroughSubject<Void, Never>()
        
        ///
        let connection =
            valueAccessor
                .willSet
                .registerReaction { _ in
                    subject.send()
                }
        
        ///
        let newConnectedObjectWillChange =
            ConnectedObjectWillChange(
                objectWillChange: subject.eraseToAnyPublisher(),
                connection: connection
            )
        
        ///
        MainActorValueAccessor_objectWillChange
            .mutateValue {
                $0[valueAccessor.rootObjectID] = newConnectedObjectWillChange
            }
        
        ///
        return newConnectedObjectWillChange.objectWillChange
    }
}

///
fileprivate let MainActorValueAccessor_objectWillChange: MainActorValue<[ObjectID: ConnectedObjectWillChange]>
    = .init(initialValue: [:])

///
fileprivate struct ConnectedObjectWillChange: ExpressionErgonomic {
    let objectWillChange: AnyPublisher<Void, Never>
    let connection: Any
}
