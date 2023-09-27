//
//  Plane.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-09-10.
//

import SwiftUI
import SceneKit

class Plane{
    var normal:SCNVector3
    var d: SCNFloat
    var normalLength:SCNFloat
    var distance:SCNFloat
    
    init(normal:SCNVector3,point:SCNVector3){
        self.normal = normal
        normalLength = normal.length
        d = -normal.dotProduct(v2: point)
        distance = -d / normalLength
    }
    
    // MARK: CLASS FUNCTIONS
    func normalize(){
        let lengthInv = 1.0/normalLength
        normal = normal.mulEqualF(a: lengthInv)
        normalLength = 1.0
        d *= lengthInv
        distance = -d
    }
        
    func intersectLine(_ line:SCNLine) -> SCNVector3?{
        guard let p = line.point,
              let v = line.direction
        else { return nil }
            
        let dot1 = normal.dotProduct(v2: p)
        let dot2 = normal.dotProduct(v2: v)
        
        if(dot2 == 0){ return nil }
        let t = -(dot1+d) / dot2
        return p.add(v.mult(t))
    }
        
}
