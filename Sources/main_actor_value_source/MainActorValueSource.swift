//
//  MainActorValueSource.swift
//  
//
//  Created by Jeremy Bannister on 10/20/22.
//

///
@MainActor
public final class MainActorValueSource<Value>: Interface_SubscribableMainActorValue,
                                                Interface_MainActorValueSource,
                                                ReferenceType {
    
    ///
    public convenience init(
        initialValue: Value,
        leakTracker: LeakTracker,
        withDeepChangeMonitoring: Void
    )
    where Value: Interface_MainActorValueSourceAccessor {
        
        ///
        self.init(
            initialValue: initialValue,
            leakTracker: leakTracker
        )
        
        ///
        setupChangeNotificationForwarding(
            sourceObjectID: self.objectID,
            generateValue: .init { [weak self] in self?.currentValue },
            _willSet: self._willSet,
            _didSet: self._didSet,
            leakTracker: leakTracker["setupChangeNotificationForwarding"]
        )
    }
    
    ///
    public convenience init(
        initialValue: Value,
        leakTracker: LeakTracker
    ) {
        
        ///
        self.init(
            _valueStorage: .value(initialValue),
            leakTracker: leakTracker
        )
    }
    
    ///
    public nonisolated convenience init(
        initialValue: Value,
        leakTracker: LeakTracker,
        nonisolatedOverload: Void
    ) {
        
        ///
        self.init(
            _valueStorage: .value(initialValue),
            leakTracker: leakTracker,
            nonisolatedOverload: ()
        )
    }
    
    ///
    public convenience init(
        uninitializedValue: @escaping @MainActor ()->Value,
        leakTracker: LeakTracker
    ) {
        
        ///
        self.init(
            _valueStorage: .notYetComputed(uninitializedValue),
            leakTracker: leakTracker
        )
    }
    
    ///
    public nonisolated convenience init(
        uninitializedValue: @escaping @MainActor ()->Value,
        leakTracker: LeakTracker,
        nonisolatedOverload: Void
    ) {
        
        ///
        self.init(
            _valueStorage: .notYetComputed(uninitializedValue),
            leakTracker: leakTracker,
            nonisolatedOverload: ()
        )
    }
    
    ///
    private init(
        _valueStorage: ValueStorage,
        leakTracker: LeakTracker
    ) {
        
        ///
        self._valueStorage = _valueStorage
        self._willSet =
            MainActorReactionManager(
                leakTracker: leakTracker["_willSet"]
            )
        self._didSet =
            MainActorReactionManager(
                leakTracker: leakTracker["_didSet"]
            )
        
        ///
        leakTracker.track(self)
    }
    
    ///
    private nonisolated init(
        _valueStorage: ValueStorage,
        leakTracker: LeakTracker,
        nonisolatedOverload: Void
    ) {
        
        ///
        self._valueStorage = _valueStorage
        self._willSet =
            MainActorReactionManager(
                leakTracker: leakTracker["_willSet"],
                nonisolatedOverload: ()
            )
        self._didSet =
            MainActorReactionManager(
                leakTracker: leakTracker["_didSet"],
                nonisolatedOverload: ()
            )
        
        ///
        Task { @MainActor in
            leakTracker.track(self)
        }
    }
    
    ///
    private var _valueStorage: ValueStorage
    
    ///
    private enum ValueStorage {
        case value(Value)
        case notYetComputed(@MainActor ()->Value)
    }
    
    ///
    package nonisolated let _willSet: MainActorReactionManager<Void>
    package nonisolated let _didSet: MainActorReactionManager<Value>
}

///
internal extension MainActorValueSource {
    
    /// We need didSet_erased internally because for older OS versions we don't have "runtime support for parameterized protocol types".
    nonisolated var didSet_erased: any Interface_MainActorReactionManager { _didSet }
}

///
extension MainActorValueSource {
    
    ///
    public nonisolated var willSet: any Interface_MainActorReactionManager<Void> { _willSet }
    public nonisolated var didSet: any Interface_MainActorReactionManager<Value> { _didSet }
    
    ///
    public var currentValue: Value {
        
        ///
        get {
            
            ///
            let valueToReturn: Value
            
            ///
            switch _valueStorage {
                
            ///
            case .value (let value):
                
                ///
                valueToReturn = value
                
            ///
            case .notYetComputed (let computeValue):
                
                ///
                let value = computeValue()
                
                ///
                self._valueStorage = .value(value)
                
                ///
                valueToReturn = value
            }
            
            ///
            MainActorValueSourceMonitor
                .shared
                .report(accessOf: self)
            
            ///
            return valueToReturn
        }
        
        ///
        set {
            
            ///
            for reaction in _willSet.orderedReactions {
                reaction(())
            }
            
            ///
            _valueStorage = .value(newValue)
            
            ///
            for reaction in _didSet.orderedReactions {
                reaction(newValue)
            }
        }
    }
    
    ///
    public func setValue(to newValue: Value) {
        self.currentValue = newValue
    }
    
    ///
    public func mutateValue(using mutation: (inout Value)->()) {
        var copy = currentValue
        mutation(&copy)
        self.currentValue = copy
    }
}
