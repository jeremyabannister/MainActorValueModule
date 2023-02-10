//
//  MainActorValueSourceMonitor.swift
//  
//
//  Created by Jeremy Bannister on 2/10/23.
//

///
@_exported import MainActorValueModule_main_actor_value_source


///
public actor MainActorValueSourceMonitor {
    
    ///
    public static let shared: MainActorValueSourceMonitor = MainActorValueSourceMonitor()
    
    ///
    private init () { }
    
    ///
    @MainActor
    private var logsOfAccessesToSources: [UUID: [ObjectID: any MainActorValueSource]] = [:]
    
    ///
    @MainActor
    public func generateValueAndReportAccessedSources
        <Value>
        (using generateValue: @escaping @MainActor ()->Value)
    -> (value: Value, accessedSources: [ObjectID: any MainActorValueSource]) {
        
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
    fileprivate func report (accessOf source: any MainActorValueSource) {
        for (key, accessLog) in valueAccessLogs {
            valueAccessLogs[key] =
                accessLog
                    .setting(
                        \.[source.objectID],
                         to: source
                    )
        }
    }
}
