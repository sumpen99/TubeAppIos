//
//  AppMethods.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-06-10.
//

import SwiftUI

func printSimulator(){
    #if targetEnvironment(simulator)
    #else
    #endif
}

func debugLog(object: Any, functionName: String = #function, fileName: String = #file, lineNumber: Int = #line){
  #if DEBUG
    let className = (fileName as NSString).lastPathComponent
    print("<\(className)> \(functionName) [#\(lineNumber)]| \(object)\n")
  #endif
}

func fakePauseWith(delay waitInSec:DispatchTime,action:@escaping ()->Void){
    //.now() + 4
    DispatchQueue.main.asyncAfter(deadline: waitInSec, execute: {
        action()
    })
}
