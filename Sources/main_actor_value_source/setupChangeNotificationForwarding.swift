//
//  setupChangeNotificationForwarding.swift
//  
//
//  Created by Jeremy Bannister on 2/22/23.
//

///
@MainActor
internal func setupChangeNotificationForwarding<
    Value
>(
    sourceObjectID: ObjectID?,
    generateValue: MainActorClosure_0Inputs<Value?>,
    _willSet: MainActorReactionManager<Void>,
    _didSet: MainActorReactionManager<Value>,
    leakTracker: LeakTracker
) {
    
    ///
    let uniqueID = UUID()
    
    ///
    let latestAccessedSources: MainActorValueSource<[ObjectID: any Interface_MainActorValueSource]> =
        .init(
            initialValue: [:],
            leakTracker: leakTracker
        )
    
    ///
    weak var weak_willSet = _willSet
    weak var weak_didSet = _didSet
    weak var weak_generateValue = generateValue
    
    ///
    @MainActor
    func updateWillSetAndDidSet(
        for newAccessedSources: [ObjectID: any Interface_MainActorValueSource]
    ) {
        
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
                // We used didSet_erased because for older OS versions we don't have "runtime support for parameterized protocol types".
                .didSet_erased
                .unregisterReaction(forKey: uniqueID.uuidString)
        }
        
        ///
        for newSourceID in newSourceIDs {
            
            ///
            guard let newSource = newAccessedSources[newSourceID] else { continue }
            
            ///
            newSource
                .willSet
                .registerReaction(key: uniqueID.uuidString) { _ in
                    for reaction in (weak_willSet?.orderedReactions ?? []) {
                        reaction(())
                    }
                }
            
            ///
            newSource
                .didSet_erased
                .registerReaction(key: uniqueID.uuidString) { _ in
                    
                    ///
                    guard let newValue = weak_generateValue?() else { return }
                    
                    ///
                    for reaction in (weak_didSet?.orderedReactions ?? []) {
                        reaction(newValue)
                    }
                }
        }
        
        ///
        latestAccessedSources.setValue(to: newAccessedSources)
    }
    
    ///
    @MainActor
    func updateSubscriptions() {
        
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
    let retainer: MainActorValueSource<Any?> =
        .init(
            initialValue: nil,
            leakTracker: leakTracker
        )
    
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
private extension Interface_MainActorValueSourceAccessor {
    
    ///
    @MainActor
    func checkCurrentSources() -> [ObjectID: any Interface_MainActorValueSource] {
        
        ///
        return
            MainActorValueSourceMonitor
                .shared
                .generateValueAndReportAccessedSources(
                    using: .init { self._accessCurrentSources() }
                )
                .accessedSources
    }
}
