//
//  Muff.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-08-21.
//

import SwiftUI

struct Muff{
    var points:[TPoint] = []
    var pMin:TPoint = TPoint()
    var pMax:TPoint = TPoint()
    var labels:[DimensionLabel] = []
    var centerLines:[CenterLine] = []
    var midInnerPoint:CGPoint = CGPoint(x: 0.0, y: 0.0)
    var midOuterPoint:CGPoint = CGPoint(x: 0.0, y: 0.0)
    var lenInner:CGFloat = 0.0
    var lenOuter:CGFloat = 0.0
    var l1:[CGPoint] = []
    var l2:[CGPoint] = []
    
    var equalSizeL1L2:Bool {
        l1.count == l2.count
    }
    
    var emptyL1OrL2:Bool {
        l1.isEmpty || l2.isEmpty
    }
    
    var width:CGFloat{
        pMax.x - pMin.x
    }
    
    var height:CGFloat{
        pMax.y - pMin.y
    }
    
    var centerX:CGFloat{
        (pMin.x + pMax.x) / 2
    }
    
    var centerY:CGFloat{
        (pMin.y + pMax.y) / 2
    }
    
    var labelOne:String{
        return labels.isEmpty ? "" : "\(labels[0].text)°"
    }
    
    var labelTwo:String{
        return labels.count < 2 ? labelOne : "\(labelOne) & \(labels[1].text)°"
    }
  
    mutating func addLabel(_ lbl:DimensionLabel){
        self.labels.append(lbl)
    }
    
    mutating func setPoints(_ points:[TPoint]){
        self.points = points
    }
    
    mutating func setMinMax(m_in:TPoint,m_ax:TPoint){
        self.pMin = m_in
        self.pMax = m_ax
    }
    
    mutating func setL1L2(l1:[CGPoint],l2:[CGPoint]){
        self.l1 = l1
        self.l2 = l2
    }
    
    mutating func getL1L2() -> (l1:[CGPoint],l2:[CGPoint]){
        return (l1:self.l1,l2:self.l2)
    }
    
}
