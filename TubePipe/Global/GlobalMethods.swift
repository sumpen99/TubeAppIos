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

func canOpenSettingsUrl() -> Bool{
    if let url = URL(string: UIApplication.openSettingsURLString){
        return UIApplication.shared.canOpenURL(url)
    }
    return false
}

func shortId(length: Int = 4) -> String {
    var result = ""
    let base62chars:[Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz")
    let maxBase : UInt32 = 62
    let minBase : UInt16 = 32

    for _ in 0..<length {
        let random = Int(arc4random_uniform(UInt32(min(minBase, UInt16(maxBase)))))
        result.append(base62chars[random])
    }
    return result
}
