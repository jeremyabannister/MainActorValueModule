//
//  MainActorClosure_0Inputs.swift
//  
//
//  Created by Jeremy Bannister on 9/26/23.
//

///
internal final class MainActorClosure_0Inputs <Output> {
    
    ///
    private let closure: @MainActor ()->Output
    
    ///
    init(_ closure: @escaping @MainActor ()->Output) {
        self.closure = closure
    }
    
    ///
    @MainActor
    func callAsFunction() -> Output {
        closure()
    }
}
