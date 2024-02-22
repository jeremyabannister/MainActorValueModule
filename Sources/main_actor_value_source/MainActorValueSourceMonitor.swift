//
//  MainActorValueSourceMonitor.swift
//  
//
//  Created by Jeremy Bannister on 2/10/23.
//

///
internal actor MainActorValueSourceMonitor {
    
    ///
    static let shared: MainActorValueSourceMonitor = MainActorValueSourceMonitor()
    
    ///
    private init () { }
    
    ///
    @MainActor
    private var logsOfAccessesToSources: [UUID: [ObjectID: any Interface_MainActorValueSource]] = [:]
    
    ///
    @MainActor
    func generateValueAndReportAccessedSources<
        Value
    >(
        using generateValue: MainActorClosure_0Inputs<Value>
    ) -> (value: Value, accessedSources: [ObjectID: any Interface_MainActorValueSource]) {
        
        ///
        let uuid: UUID = .generateRandom()
        
        ///
        logsOfAccessesToSources[uuid] = [:]
        
        ///
        let value = generateValue()
        
        ///
        let accessedSources = logsOfAccessesToSources[uuid] ?? [:]
        
        ///
        logsOfAccessesToSources.removeValue(forKey: uuid)
        
        ///
        return (value, accessedSources)
    }
    
    ///
    @MainActor
    func report<
        Value
    >(
        accessOf source: MainActorValueSource<Value>
    ) {
        
        ///
        for (key, accessLog) in logsOfAccessesToSources {
            logsOfAccessesToSources[key] =
                accessLog
                    .setting(
                        \.[source.objectID],
                         to: source
                    )
        }
    }
}
