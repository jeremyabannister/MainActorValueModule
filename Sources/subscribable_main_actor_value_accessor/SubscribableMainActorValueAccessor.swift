//
//  SubscribableMainActorValueAccessor.swift
//  
//
//  Created by Jeremy Bannister on 2/10/23.
//

///
@_exported import MainActorValueModule_main_actor_value_source_monitor


///
extension MainActorValueAccessor {
    
    ///
    public func madeSubscribable () -> SubscribableMainActorValueAccessor<Value> {
        SubscribableMainActorValueAccessor(
            mainActorValueAccessor: self
        )
    }
}

///
public actor SubscribableMainActorValueAccessor
    <Value>:
        MainActorValueAccessor {
    
    ///
    public init (mainActorValueAccessor: any MainActorValueAccessor<Value>) {
        self.init({ mainActorValueAccessor.currentValue })
    }
    
    ///
    public init (_ generateValue: @escaping @MainActor ()->Value) {
        self.generateValue = generateValue
    }
    
    ///
    private let generateValue: @MainActor ()->Value
    
    ///
    private let id = UUID()
    
    ///
    @MainActor
    public var currentValue: Value {
        
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
        (for newAccessedSources: [ObjectID: any MainActorValueSource]) {
        
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
    private var latestAccessedSources: [ObjectID: any MainActorValueSource] = [:]
    
    ///
    private let _willSet = MainActorReactionManager<Void>()
    private let _didSet = MainActorReactionManager<Value>()
    
    ///
    public nonisolated var didAccess: any Interface_MainActorReactionManager<Value> {
        fatalError()
    }
    
    ///
    public nonisolated var willSet: any Interface_MainActorReactionManager<Void> {
        _willSet
    }
    
    ///
    public nonisolated var didSet: any Interface_MainActorReactionManager<Value> {
        _didSet
    }
    
    ///
    public nonisolated var rootObjectID: ObjectID {
        fatalError()
    }
}
