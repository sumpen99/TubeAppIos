//
//  Segment.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-08-21.
//

import SwiftUI

enum SegType: String{
    case LENA = "Len A"
    case SEG1 = "Seg 1"
    case SEG2 = "Seg 2"
    case LENB = "Len B"
}

struct Segment: Identifiable,Hashable{
    let id:String = UUID().uuidString
    let pInner:CGPoint
    let pOuter:CGPoint
    let inner:CGFloat
    let outer:CGFloat
    let angle1:CGFloat
    let angle2:CGFloat
    let rotation:CGFloat
    let seg_type:SegType
    let index:Int
    
    var innerLength:String { "\(inner.rounded()) mm" }
    var outerLength:String { "\(outer.rounded()) mm" }
    
    func hash(into hasher: inout Hasher) {
        return hasher.combine(id)
    }
    
    static func == (lhs:Segment,rhs:Segment) -> Bool{
        return lhs.id == rhs.id
    }
    
    func printSelf(){
        debugLog(object: "\(inner) \(outer) \(angle1) \(angle2) \(rotation)")
    }
}
