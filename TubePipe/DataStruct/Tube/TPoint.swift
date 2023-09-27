//
//  Point.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-06-14.
//

import SwiftUI

struct TPoint{
    var x: CGFloat = 0.0
    var y: CGFloat = 0.0
    var length: CGFloat { sqrt(pow(self.x,2) + pow(self.y,2)) }
    
    var description: String {
        "x:\(x) y:\(y) length:\(length)"
    }
    
    func getCgPoint() ->CGPoint{
        return CGPoint(x:self.x,y:self.y)
    }
    
    static func equal(p1:TPoint?,p2:TPoint?) -> Bool{
        guard let p1 = p1,let p2 = p2 else { return false}
        return p1.x == p2.x && p1.y == p2.y
    }
    
    static func sub(p1:TPoint,p2:TPoint) -> TPoint{
        return TPoint(x:p1.x - p2.x,y:p1.y - p2.y)
    }
    
    static func mult(p:TPoint,m:CGFloat) -> TPoint{
        return TPoint(x:p.x * m,y:p.y * m)
    }
    
    static func add(p:TPoint,a:CGFloat) -> TPoint{
        return TPoint(x:p.x + a,y:p.y + a)
    }
    
    static func div(p:TPoint,d:CGFloat) -> TPoint{
        return TPoint(x:p.x / d,y:p.y / d)
    }
    
    static func addPoint(p1:TPoint,p2:TPoint) -> TPoint{
        return TPoint(x:p1.x + p2.x,y:p1.y + p2.y)
    }
    
    static func minX(p1:TPoint,p2:TPoint) -> TPoint{
        return p1.x <= p2.x ? p1 : p2
    }
    
    static func maxX(p1:TPoint,p2:TPoint) -> TPoint{
        return p1.x >= p2.x ? p1 : p2
    }
    
    static func minY(p1:TPoint,p2:TPoint) -> TPoint{
        return p1.y <= p2.y ? p1 : p2
    }
    
    static func maxY(p1:TPoint,p2:TPoint) -> TPoint{
        return p1.y >= p2.y ? p1 : p2
    }
}
