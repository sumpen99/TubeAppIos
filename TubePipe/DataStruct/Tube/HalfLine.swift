//
//  HalfLine.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-06-17.
//
import SwiftUI
struct HalfLine{
    var tangent:TPoint = TPoint()
    var p:TPoint
    var r:TPoint
    var n:TPoint = TPoint()
    var ext:TPoint = TPoint()
    var half:TPoint = TPoint()
    var a:CGFloat = 0.0
    var b:CGFloat = 0.0
    var c:CGFloat = 0.0
    var dx:CGFloat = 0.0
    var dy:CGFloat = 0.0
    var length:CGFloat = 0.0
    var angle:CGFloat = 0.0
    var angle_angle:CGFloat = 0.0
    var scale:CGFloat
    var halfCgPoint:CGPoint{ CGPoint(x: half.x, y: half.y) }
  
    init(p:TPoint,r:TPoint,scale:CGFloat){
        self.p = p
        self.r = r
        self.scale = scale
        updateValues()
    }
    
    init(p:TPoint,r:TPoint){
        self.init(p:p,r:r,scale:1.0)
    }
    
    func offset(t:CGFloat) -> HalfLine{
        return HalfLine(p: TPoint.addPoint(p1: self.p, p2: TPoint.mult(p: self.n, m: t)),
                        r: TPoint.addPoint(p1: self.r, p2: TPoint.mult(p: self.n, m: t)))
     
    }
    
    func intersect(other:HalfLine) -> TPoint?{
        let det = self.a * other.b - other.a * self.b
        
        if abs(det) < 1e-5 { return nil }
        
        let x = (other.b * self.c - self.b * other.c) / det
        let y = (self.a * other.c - other.a * self.c) / det
        
        return TPoint(x:x,y:y)
    }
    
    func pointOnLine(n:CGFloat) -> TPoint{
        //let d = sqrt(pow(r.x-p.x,2.0) + sqrt(pow(r.y-p.y,2.0)))
        let d = length
        let ratio = n / d
        let x = ratio * r.x + (1.0 - ratio) * p.x
        let y = ratio * r.y + (1.0 - ratio) * p.y
        return TPoint(x: x, y: y)
    }
    
    mutating func rotateLine(angle:CGFloat,base:Int = 1){
        if base == 1{
            let x = length * sin(angle) + self.p.x
            let y = length * cos(angle) + self.p.y
            self.r.x = x
            self.r.y = y
        }
        else{
            let x = length * sin(angle) + self.r.x
            let y = length * cos(angle) + self.r.y
            self.p.x = x
            self.p.y = y
        }
        updateValues()
    }
    
    mutating func updateValues(){
        tangent = TPoint.sub(p1: self.r, p2: self.p)
        self.a = -tangent.y
        self.b = tangent.x
        self.c = self.p.x * self.a + self.p.y * self.b
        
        let n = TPoint(x:self.a,y:self.b)
        
        self.n = TPoint.div(p: n, d: n.length)
        
        calcLengthOfLine()
        calcAngleOfLine()
    }
    
    mutating func calcLengthOfLine(){
        self.length = CGFloat(sqrt(pow(r.x - p.x,2) + pow(r.y - p.y,2)) / scale).roundWith(precision: .HUNDREDTHS)
        self.half = TPoint(x:(r.x + p.x) / 2.0,y:(r.y + p.y) / 2.0)
    }
    
    mutating func calcAngleOfLine(){
        let dy = self.r.y - self.p.y
        let dx = self.r.x - self.p.x
        
        let theta = CGFloat(atan2(dy, dx)).radToDeg()
        
        self.angle = 90.0 + theta
        self.dx = dx
        self.dy = dy
    }
    
    mutating func angleBetweenLines(l2:HalfLine){
        let angle = atan2(dx * l2.dy - l2.dx * dy,
                          dx * l2.dx + dy * l2.dy)
        angle_angle = CGFloat(abs(angle)).radToDeg()
    }
    
    mutating func extendLine(len:CGFloat){
        let cx = r.x + (r.x - p.x) / length * len
        let cy = r.y + (r.y - p.y) / length * len
        
        ext = TPoint(x:cx,y:cy)
        half = TPoint(x:(ext.x + p.x) / 2.0,y:(ext.y + p.y) / 2.0)
    }
    
    mutating func extendLineAndKeep(len:CGFloat){
        let cx = r.x + (r.x - p.x) / length * len
        let cy = r.y + (r.y - p.y) / length * len
        
        ext = TPoint(x:cx,y:cy)
        half = TPoint(x:(ext.x + p.x) / 2.0,y:(ext.y + p.y) / 2.0)
        r = ext
        updateValues()
    }
    
    mutating func halfPoint(){
        let cx = r.x + (r.x - p.x) / length
        let cy = r.y + (r.y - p.y) / length
        ext = TPoint(x:cx,y:cy)
    }
    
    static func offsetLineSegments2(points:[TPoint],offset:CGFloat) -> (l1:[CGPoint],l2:[CGPoint]){
        var l1:[CGPoint] = []
        var l2:[CGPoint] = []
        
        let size = points.count
        
        for i in (0..<size){
            let i0 = max(0, i - 1)
            let i1 = min(size - 1, i + 1)
            let p0 = points[i]
            let p1 = points[i0]
            let p2 = points[i1]
            
            let dx = p2.x - p1.x
            let dy = p2.y - p1.y
            
            let L = pow(pow(dx,2) + pow(dy,2),0.5)
            let nx = -offset*dy / L
            let ny = offset*dx / L
            
            l1.append(CGPoint(x: p0.x - nx, y: p0.y - ny))
            l2.append(CGPoint(x: p0.x + nx, y: p0.y + ny))
            
        }
        return (l1:l1,l2:l2)
    }
    
    static func offsetCenterLine(points:[TPoint],offset:CGFloat) -> [TPoint]{
        var l1:[TPoint] = []
        let size = points.count
        for i in (0..<size){
            if i == 0 || i == size-1{
                let tangent =  i == 0 ? TPoint.sub(p1: points[i+1], p2: points[i]) :
                                        TPoint.sub(p1: points[i], p2: points[i-1])
                
                let n = TPoint(x:-tangent.y,y:tangent.x)
                let normal = TPoint.div(p: n, d: n.length)
                let p1 = TPoint.addPoint(p1: points[i], p2: TPoint.mult(p: normal, m: offset))
                l1.append(p1)
            }
            else{
                let prevSegment = HalfLine(p: points[i-1], r: points[i])
                let nextSegment = HalfLine(p: points[i], r: points[i+1])
                let n1 = prevSegment.offset(t: offset).intersect(other: nextSegment.offset(t: offset))
                var p1:TPoint
                if n1 != nil{
                    p1 = n1 ?? TPoint()
                }
                else{
                    p1 = TPoint.addPoint(p1: points[i], p2: TPoint.mult(p: prevSegment.n, m: offset))
                }
                l1.append(p1)
            }
        }
        return l1
    }
    
    static func offsetLineSegments(points:[TPoint],offset:CGFloat) -> (l1:[CGPoint],l2:[CGPoint]){
        var l1:[CGPoint] = []
        var l2:[CGPoint] = []
        let size = points.count
        for i in (0..<size){
            if i == 0 || i == size-1{
                let tangent =  i == 0 ? TPoint.sub(p1: points[i+1], p2: points[i]) :
                                        TPoint.sub(p1: points[i], p2: points[i-1])
                
                let n = TPoint(x:-tangent.y,y:tangent.x)
                let normal = TPoint.div(p: n, d: n.length)
               
                let p1 = TPoint.addPoint(p1: points[i], p2: TPoint.mult(p: normal, m: offset))
                let p2 = TPoint.addPoint(p1: points[i], p2: TPoint.mult(p: normal, m: -offset))
                l1.append(CGPoint(x: p1.x, y: p1.y))
                l2.append(CGPoint(x: p2.x, y: p2.y))
            }
            else{
                let prevSegment = HalfLine(p: points[i-1], r: points[i])
                let nextSegment = HalfLine(p: points[i], r: points[i+1])
                
                let n1 = prevSegment.offset(t: offset).intersect(other: nextSegment.offset(t: offset))
                let n2 = prevSegment.offset(t: -offset).intersect(other: nextSegment.offset(t: -offset))
                
                var p1:TPoint
                var p2:TPoint
                
                if n1 != nil{
                    p1 = n1 ?? TPoint()
                }
                else{
                    p1 = TPoint.addPoint(p1: points[i], p2: TPoint.mult(p: prevSegment.n, m: offset))
                }
                if n2 != nil{
                    p2 = n2 ?? TPoint()
                }
                else{
                    p2 = TPoint.addPoint(p1: points[i], p2: TPoint.mult(p: prevSegment.n, m: -offset))
                }
                l1.append(CGPoint(x: p1.x, y: p1.y))
                l2.append(CGPoint(x: p2.x, y: p2.y))
            }
        }
        return (l1:l1,l2:l2)
    }
    
    static func fixOverlaps(polyline:[TPoint]) -> [TPoint]{
        func onSegment(p1:TPoint,p2:TPoint,p:TPoint) -> Bool{
            return  p.x >  min(p1.x,p2.x) &&
                    p.x <= max(p1.x,p2.x) &&
                    p.y >  min(p1.y,p2.y) &&
                    p.y <= max(p1.y,p2.y)
        }
        
        func crossProduct(p1:TPoint,p2:TPoint) -> CGFloat{
            return p1.x * p2.y - p2.x * p1.y
        }
        
        func direction(p1:TPoint,p2:TPoint,p3:TPoint) -> CGFloat{
            return crossProduct(p1: TPoint.sub(p1: p3, p2: p1), p2: TPoint.sub(p1: p2, p2: p1))
        }
        
        func segmentsIntersect(p1:TPoint,p2:TPoint,p3:TPoint,p4:TPoint) -> Bool{
            let d1 = direction(p1: p3, p2: p4, p3: p1)
            let d2 = direction(p1: p3, p2: p4, p3: p2)
            let d3 = direction(p1: p1, p2: p2, p3: p3)
            let d4 = direction(p1: p1, p2: p2, p3: p4)
            
            return (((( d1 > 0 && d2 < 0) || (d1 < 0 && d2 > 0)) &&
                      ((d3 > 0 && d4 < 0) || (d3 < 0 && d4 > 0))) ||
                    (d1 == 0 && onSegment(p1: p3, p2: p4, p: p1)) ||
                    (d2 == 0 && onSegment(p1: p3, p2: p4, p: p2)) ||
                    (d3 == 0 && onSegment(p1: p1, p2: p2, p: p3)) ||
                    (d4 == 0 && onSegment(p1: p1, p2: p2, p: p4)))
        }
        
        var intersectionsFound = true
        
        while(intersectionsFound){
            var result:[TPoint] = [polyline[0]]
            var i = 0
            while i < polyline.count {
                let j = i + 2
                while j < polyline.count{
                    if segmentsIntersect(p1: polyline[i-1], p2: polyline[i], p3: polyline[j-1], p4: polyline[j]){
                        let s = HalfLine(p: polyline[i-1], r: polyline[i])
                        let t = HalfLine(p: polyline[j-1], r: polyline[j])
                        guard let s = s.intersect(other: t) else { break; }
                        result.append(s)
                        i = j
                        break
                    }
                }
                result.append(polyline[i])
                i += 1
            }
            intersectionsFound = polyline.count > result.count
        }
        return polyline
    }
    
}
