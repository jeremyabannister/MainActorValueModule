//
//  MainActorValue.swift
//  
//
//  Created by Jeremy Bannister on 10/20/22.
//

///
@_exported import MainActorValueModule_abstract

///
@propertyWrapper
public final class MainActorValue
    <Value>:
        MainActorValueAccessor,
        ObservableObject,
        ReferenceType {
    
    ///
    public nonisolated var projectedValue: MainActorValue<Value> {
        self
    }
    
    ///
    @MainActor
    public var wrappedValue: Value {
        get { valueAccess.get() }
        set {
            objectWillChange.send()
            valueAccess.set(newValue)
        }
    }
    
    ///
    public convenience init (wrappedValue: Value) {
        
        ///
        self.init(
            wrappedValue: wrappedValue,
            didSet: { _ in }
        )
    }
    
    ///
    public convenience init
        (wrappedValue: Value,
         didSet: @escaping @MainActor (Value)->()) {
        
        ///
        self.init(
            wrappedValue: .initialized(wrappedValue),
            didSet: didSet
        )
    }
    
    ///
    public convenience init
        (uninitializedValue: @escaping @MainActor ()->Value,
         didSet: @escaping @MainActor (Value)->()) {
        
        ///
        self.init(
            wrappedValue: .uninitialized(uninitializedValue),
            didSet: didSet
        )
    }
    
    ///
    private convenience init
        (wrappedValue: ValueAccess.Storage,
         didSet: @escaping @MainActor (Value)->()) {
        
        ///
        let didSetSubject = PassthroughSubject<Value, Never>()
        
        ///
        self.init(
            valueAccess: .stored(
                wrappedValue,
                didSet: {
                    didSet($0)
                    didSetSubject.send($0)
                }
            ),
            objectWillChangePublisher: .init(),
            didSetPublisher: didSetSubject.eraseToAnyPublisher()
        )
    }
    
    ///
    private nonisolated init
        (valueAccess: ValueAccess,
         objectWillChangePublisher: ObservableObjectPublisher,
         didSetPublisher: AnyPublisher<Value, Never>) {
        
        self.valueAccess = valueAccess
        self.objectWillChange = objectWillChangePublisher
        self.didSetPublisher = didSetPublisher
    }
    
    ///
    private nonisolated let didSetPublisher: AnyPublisher<Value, Never>
    
    ///
    public nonisolated let objectWillChange: ObservableObjectPublisher
    
    ///
    @MainActor
    private var valueAccess: ValueAccess
    
    ///
    private enum ValueAccess {
        case stored (Storage, didSet: @MainActor (Value)->())
        case computed (getter: @MainActor ()->Value,
                       setter: @MainActor (Value)->())
        
        enum Storage {
            case initialized (Value)
            case uninitialized (@MainActor ()->Value)
        }
        
        ///
        @MainActor
        mutating func get () -> Value {
            switch self {
            case .stored (let storage, let didSet):
                switch storage {
                case .initialized (let value):
                    return value
                case .uninitialized (let valueGenerator):
                    let value = valueGenerator()
                    self = .stored(.initialized(value), didSet: didSet)
                    return value
                }
            case .computed (let getter, _):
                return getter()
            }
        }
        
        ///
        @MainActor
        mutating func set (_ newValue: Value) {
            switch self {
            case .stored (_, let didSet):
                self = .stored(.initialized(newValue), didSet: didSet)
                didSet(newValue)
                
            case .computed(_, let setter):
                setter(newValue)
            }
        }
    }
}

///
public extension MainActorValue {
    
    ///
    @MainActor
    var value: Value {
        get { wrappedValue }
        set { wrappedValue = newValue }
    }
    
    ///
    @MainActor
    func setValue (to newValue: Value) {
        wrappedValue = newValue
    }
    
    ///
    @MainActor
    func mutateValue (using mutation: (inout Value)->()) {
        mutation(&wrappedValue)
    }
    
    ///
    nonisolated var didSet: AnyPublisher<Value, Never> {
        didSetPublisher
    }
}
