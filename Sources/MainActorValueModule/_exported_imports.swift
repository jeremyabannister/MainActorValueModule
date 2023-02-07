//
//  _exported_imports.swift
//  
//
//  Created by Jeremy Bannister on 10/25/22.
//

///
@_exported import MainActorValueModule_concrete
@_exported import MainActorValueModule_map

///
#if false
public typealias MainActorValue = MainActorValue_new
public typealias MainActorValueAccessor = MainActorValueAccessor_new
#else
public typealias MainActorValue = MainActorValue_old
public typealias MainActorValueAccessor = MainActorValueAccessor_old
#endif
