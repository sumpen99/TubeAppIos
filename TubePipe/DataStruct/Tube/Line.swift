//
//  Line.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-06-14.
//

import SwiftUI

struct CenterLine{
    var p1:CGPoint
    var p2:CGPoint
}

struct Line{
    var p1:TPoint
    var p2:TPoint
    var lengthOfLine: CGFloat = 0.0
    
    var description:String {
        "p1:\(p1.description) p2:\(p2.description) length: \(lengthOfLine)"
    }
    
    init(p1:TPoint,p2:TPoint){
        self.p1 = p1
        self.p2 = p2
        self.lengthOfLine = sqrt(pow(p2.x - p1.x,2) + pow(p2.y - p1.y,2))
    }
    
    static func calcLengthOfLine(p1:TPoint,p2:TPoint) -> CGFloat {
        return sqrt(pow(p2.x - p1.x,2) + pow(p2.y - p1.y,2))
    }
    
    static func calcLengthOfLine(p1:CGPoint,p2:CGPoint) -> CGFloat {
        return sqrt(pow(p2.x - p1.x,2) + pow(p2.y - p1.y,2))
    }
    
    static func calcLengthOfLine(x1:CGFloat,y1:CGFloat,x2:CGFloat,y2:CGFloat) -> CGFloat {
        return sqrt(pow(x2 - x1,2) + pow(y2 - y1,2))
    }
    
    static func calcAngleOfLine(x1:CGFloat,y1:CGFloat,x2:CGFloat,y2:CGFloat) -> CGFloat {
        
        let dy = y2 - y1
        let dx = x2 - x1
        var theta = atan2(dy,dx)
        theta *= 180 / CGFloat.pi
        
        return theta
    }
    
    static func checkForLineIntersection(inputSegments:[[CGPoint]]) -> Bool{
        for lines in inputSegments{
            let inputLines = buildLineSegment(line:lines)
            if sweepAdvanced(lines:inputLines) { return true }
        }
        return false
    }
                
    static func buildLineSegment(line:[CGPoint]) -> [Line]{
        var segLines:[Line] = []
        
        for i in (1..<line.count){
            let p1 = line[i-1]
            let p2 = line[i]
            if p1.x == p2.x && p1.y == p2.y { continue }
            segLines.append(Line(p1: TPoint(x:p1.x,y:p1.y), p2: TPoint(x:p2.x,y:p2.y)))
        }
        return segLines
    }
    
    static func sweepAdvanced(lines:[Line]) -> Bool{
        for (i1,seg1) in lines.enumerated(){
            let next = i1+1
            for i2 in (next..<lines.count){
                let seg2 = lines[i2]
                let p0 = seg1.p1
                let p1 = seg1.p2
                let q0 = seg2.p1
                let q1 = seg2.p2
                
                if !(TPoint.equal(p1: p0, p2: q0) ||
                    TPoint.equal(p1: p0, p2: q1) ||
                    TPoint.equal(p1: p1, p2: q0) ||
                    TPoint.equal(p1: p1, p2: q1)){
                    
                    if let _ = lineLineIntersect(p0:p0,p1:p1,q0:q0,q1:q1){
                        //let out = "\(i1+1) \(i2+(i1+1)) \(isectP.x) \(isectP.y)"
                        //debugLog(object: out)
                        return true
                    }
                }
            }
        }
        return false
    }
    
    static func lineLineIntersect(p0:TPoint,p1:TPoint,q0:TPoint,q1:TPoint) -> TPoint?{
        let d = (p1.x - p0.x) * (q1.y - q0.y) + (p1.y - p0.y) * (q0.x - q1.x)
        if d == 0.0{
            return nil
        }
        
        let t = ((q0.x - p0.x) * (q1.y - q0.y) + (q0.y - p0.y) * (q0.x - q1.x)) / d
        let u = ((q0.x - p0.x) * (p1.y - p0.y) + (q0.y - p0.y) * (p0.x - p1.x)) / d
    
        if (0.0 <= t && t <= 1.0) && (0.0 <= u && u <= 1.0){
            return TPoint(x: round(p1.x * t + p0.x * (1.0 - t)),y: round(p1.y * t + p0.y * (1.0 - t)))
        }
        return nil
    }
}
