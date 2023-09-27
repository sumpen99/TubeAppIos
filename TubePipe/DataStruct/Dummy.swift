//
//  Dummy.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-08-08.
//

import SwiftUI

class Dummy{
    let name:String
    
    init(_ name:String){
        self.name = name
        debugLog(object:"\(self.name)")
    }
    
    deinit {
        debugLog(object:"\(self.name)")
    }
}
