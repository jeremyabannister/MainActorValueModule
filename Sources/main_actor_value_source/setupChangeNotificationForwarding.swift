//
//  setupChangeNotificationForwarding.swift
//  
//
//  Created by Jeremy Bannister on 2/22/23.
//

///
@MainActor
internal func setupChangeNotificationForwarding
    <Value>
    (sourceObjectID: ObjectID?,
     generateValue: @escaping @MainActor ()->Value?,
     _willSet: MainActorReactionManager<Void>,
     _didSet: MainActorReactionManager<Value>) {
    
    ///
    let uniqueID = UUID()
    
    ///
    let latestAccessedSources =
        MainActorValueSource<[ObjectID: any Interface_MainActorValueSource]>(initialValue: [:])
    
    ///
    @MainActor
    func updateWillSetAndDidSet
        (for newAccessedSources: [ObjectID: any Interface_MainActorValueSource]) {
        
        ///
        let staleSourceIDs: Set<ObjectID> =
            latestAccessedSources
                .currentValue
                .keys
                .asSet()
                .subtracting(newAccessedSources.keys)
        
        ///
        let newSourceIDs: Set<ObjectID> =
            newAccessedSources
                .keys
                .asSet()
                .subtracting(latestAccessedSources.currentValue.keys)
        
        ///
        for staleSourceID in staleSourceIDs {
            
            ///
            latestAccessedSources
                .currentValue[staleSourceID]?
                .willSet
                .unregisterReaction(forKey: uniqueID.uuidString)
            
            ///
            latestAccessedSources
                .currentValue[staleSourceID]?
                .didSet
                .unregisterReaction(forKey: uniqueID.uuidString)
        }
        
        ///
        for newSourceID in newSourceIDs {
            
            ///
            guard let newSource = newAccessedSources[newSourceID] else { continue }
            
            ///
            newSource
                .willSet
                .registerReaction(key: uniqueID.uuidString) { [_willSet] _ in
                    for reaction in _willSet.orderedReactions {
                        reaction(())
                    }
                }
            
            ///
            newSource
                .didSet_Void
                .registerReaction(key: uniqueID.uuidString) { [_didSet] _ in
                    
                    ///
                    guard let newValue = generateValue() else { return }
                    
                    ///
                    for reaction in _didSet.orderedReactions {
                        reaction(newValue)
                    }
                }
        }
        
        ///
        latestAccessedSources.setValue(to: newAccessedSources)
    }
    
    ///
    @MainActor
    func updateSubscriptions () {
        
        ///
        var (value, accessedSources) =
            MainActorValueSourceMonitor
                .shared
                .generateValueAndReportAccessedSources(
                    using: generateValue
                )
        
        ///
        if let sourceAccessor = value as? any Interface_MainActorValueSourceAccessor {
            
            ///
            accessedSources
                .pasteIn(
                    sourceAccessor
                        .checkCurrentSources()
                )
        }
        
        ///
        updateWillSetAndDidSet(
            for: accessedSources.filter { $0.key != sourceObjectID }
        )
    }
    
    ///
    let retainer = MainActorValueSource<Any?>(initialValue: nil)
    
    ///
    retainer
        .setValue(
            to:
                _didSet
                    .registerReaction { [retainer] _ in
                        
                        /// Silence the warning - the retainer is captured deliberately so that it's lifetime is tied to the `_didSet`.
                        _ = retainer
                        
                        ///
                        updateSubscriptions()
                    }
        )
    
    ///
    updateSubscriptions()
}

///
fileprivate extension Interface_MainActorValueSourceAccessor {
    
    ///
    @MainActor
    func checkCurrentSources () -> [ObjectID: any Interface_MainActorValueSource] {
        
        ///
        return
            MainActorValueSourceMonitor
                .shared
                .generateValueAndReportAccessedSources(
                    using: { self.accessCurrentSources() }
                )
                .accessedSources
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
