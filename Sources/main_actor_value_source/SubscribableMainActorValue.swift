//
//  SubscribableMainActorValue.swift
//  
//
//  Created by Jeremy Bannister on 2/10/23.
//

///
extension Interface_ReadableMainActorValue {
    
    ///
    @MainActor
    public func madeSubscribable () -> SubscribableMainActorValue<Value> {
        SubscribableMainActorValue(
            readableValue: self
        )
    }
}

///
public actor
    SubscribableMainActorValue
        <Value>:
            Interface_SubscribableMainActorValue {
    
    ///
    @MainActor
    public init (readableValue: any Interface_ReadableMainActorValue<Value>) {
        self.init({ readableValue.currentValue })
    }
    
    ///
    @MainActor
    public init (_ generateValue: @escaping @MainActor ()->Value) {
        
        ///
        self.generateValue = generateValue
        
        ///
        updateSubscriptionByGeneratingValue()
    }
    
    ///
    private let generateValue: @MainActor ()->Value
    
    ///
    private let id = UUID()
    
    ///
    @MainActor
    public var currentValue: Value {
        
        ///
        return updateSubscriptionByGeneratingValue()
    }
    
    ///
    @MainActor
    @discardableResult
    private func updateSubscriptionByGeneratingValue () -> Value {
        
        ///
        let (value, accessedSources) =
            MainActorValueSourceMonitor
                .shared
                .generateValueAndReportAccessedSources(
                    using: generateValue
                )
        
        ///
        updateWillSetAndDidSet(
            for: accessedSources
        )
        
        ///
        return value
    }
    
    ///
    @MainActor
    func updateWillSetAndDidSet
        (for newAccessedSources: [ObjectID: any Interface_SubscribableMainActorValue]) {
        
        ///
        let staleSourceIDs: Set<ObjectID> =
            latestAccessedSources
                .keys
                .asSet()
                .subtracting(newAccessedSources.keys)
        
        ///
        let newSourceIDs: Set<ObjectID> =
            newAccessedSources
                .keys
                .asSet()
                .subtracting(latestAccessedSources.keys)
        
        ///
        for staleSourceID in staleSourceIDs {
            
            ///
            latestAccessedSources[staleSourceID]?
                .willSet
                .unregisterReaction(forKey: self.id.uuidString)
            
            ///
            latestAccessedSources[staleSourceID]?
                .didSet
                .unregisterReaction(forKey: self.id.uuidString)
        }
        
        ///
        for newSourceID in newSourceIDs {
            
            ///
            guard let newSource = newAccessedSources[newSourceID] else { continue }
            
            ///
            newSource
                .willSet
                .registerReaction(key: self.id.uuidString) { [_willSet] _ in
                    for reaction in _willSet.orderedReactions {
                        reaction(())
                    }
                }
            
            ///
            newSource
                .didSet_Void
                .registerReaction(key: self.id.uuidString) { [weak self] _ in
                    
                    ///
                    guard let self else { return }
                    
                    ///
                    let newValue = self.currentValue
                    
                    ///
                    for reaction in self._didSet.orderedReactions {
                        reaction(newValue)
                    }
                }
        }
        
        ///
        self.latestAccessedSources = newAccessedSources
    }
    
    ///
    @MainActor
    private var latestAccessedSources: [ObjectID: any Interface_SubscribableMainActorValue] = [:]
    
    ///
    private let _willSet = MainActorReactionManager<Void>()
    private let _didSet = MainActorReactionManager<Value>()
    
    ///
    public nonisolated var willSet: any Interface_MainActorReactionManager<Void> {
        _willSet
    }
    
    ///
    public nonisolated var didSet: any Interface_MainActorReactionManager<Value> {
        _didSet
    }
}

///
fileprivate extension Interface_SubscribableMainActorValue {
    
    ///
    var didSet_Void: any Interface_MainActorReactionManager<Void> {
        self
            .didSet
            .map { _ in () }
    }
}
