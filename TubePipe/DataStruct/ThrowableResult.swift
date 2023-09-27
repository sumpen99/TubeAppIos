//
//  ThrowableResult.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-06-10.
//

struct ThrowableResult{
    var finishedWithoutError : Bool = true
    var value : Any?
    
    func asString() -> String {
        return value as? String ?? "Unexpected Error"
    }
    func printSelf(){
        if !finishedWithoutError{
            debugLog(object:asString())
        }
        else {
            debugLog(object:"success")
        }
    }
}
