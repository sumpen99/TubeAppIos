//
//  DimensionLabel.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-08-21.
//

import SwiftUI

struct DimensionLabel: Identifiable,Hashable{
    var id:String = UUID().uuidString
    var text:String
    var pos:CGPoint
    var rotation:CGFloat
    
    func hash(into hasher: inout Hasher) {
        return hasher.combine(id)
    }
        
    static func == (lhs: DimensionLabel, rhs: DimensionLabel) -> Bool {
            return lhs.id == rhs.id
    }
}
