//
//  TubeBase.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-08-21.
//

import SwiftUI

struct TubeBase{
    var b:TPoint = TPoint(x:0.0,y:0.0)
    var bb:TPoint = TPoint(x:0.0,y:0.0)
    var p1:TPoint = TPoint(x:0.0,y:0.0)
    var p2:TPoint = TPoint(x:0.0,y:0.0)
    var p3:TPoint = TPoint(x:0.0,y:0.0)
    var pp3:TPoint = TPoint(x:0.0,y:0.0)
    var b_c:TPoint = TPoint(x:0.0,y:0.0)
    var scaledFirst:TPoint?
    var scaledLast:TPoint?
    var r1:CGFloat = 0.0
    var b_xy_p_list: [TPoint] = []
    var modelSteelPoints: [TPoint] = []
    var off_r: CGFloat = 0.0
    var centerOfTube:CGPoint = CGPoint(x:0.0,y:0.0)
    var l1: HalfLine?
    var l2: HalfLine?
    
    mutating func set(b:TPoint,
                      p1:TPoint,
                      p2:TPoint,
                      p3:TPoint,
                      r1:CGFloat){
        self.b = b
        self.p1 = p1
        self.p2 = p2
        self.p3 = p3
        self.r1 = r1
    }
    
    mutating func setOptionalAddHundred(bb:TPoint,pp3:TPoint){
        self.bb = bb
        self.pp3 = pp3
    }
    
    mutating func setModelSteelPoints(_ points:[TPoint]){
        modelSteelPoints = points
    }
    
    mutating func setScaledFirst(_ p:TPoint?){
        scaledFirst = p
    }
    
    mutating func setScaledLast(_ p:TPoint?){
        scaledLast = p
    }
    
    func getXMin() -> CGFloat{
        let m1 = TPoint.minX(p1: b, p2: p1)
        let m2 = TPoint.minX(p1: p2, p2: p3)
        
        return TPoint.minX(p1: m1, p2: m2).x
    }
    
    func getYMin() -> CGFloat{
        let m1 = TPoint.minY(p1: b, p2: p1)
        let m2 = TPoint.minY(p1: p2, p2: p3)
        
        return TPoint.minY(p1: m1, p2: m2).y
    }
    
    func getXMax() -> CGFloat{
        let m1 = TPoint.maxX(p1: b, p2: p1)
        let m2 = TPoint.maxX(p1: p2, p2: p3)
        
        return TPoint.maxX(p1: m1, p2: m2).x
    }
    
    func getYMax() -> CGFloat{
        let m1 = TPoint.maxY(p1: b, p2: p1)
        let m2 = TPoint.maxY(p1: p2, p2: p3)
        
        return TPoint.maxY(p1: m1, p2: m2).y
    }
    
    func scaledPathToModel() -> [TPoint]{
        guard let scaledFirst = scaledFirst,
              let scaledLast = scaledLast else { return pathToModel}
        var newPoints = pathToModel
        let maxCount = newPoints.count-1
        if maxCount < 0 { return pathToModel }
        newPoints[0] = scaledFirst
        newPoints[maxCount] = scaledLast
        return newPoints
    }
    
    mutating func resetScaled(){
        scaledFirst = nil
        scaledLast = nil
    }
    
    var pathToModel: [TPoint]{ modelSteelPoints }
}

