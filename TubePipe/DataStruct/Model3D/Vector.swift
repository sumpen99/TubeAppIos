//
//  Vector.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-09-09.
//

import SwiftUI
import SceneKit

enum ScnVectorDistance:SCNFloat{
    case DEFAULT = 1.0
    case CENTIMETER = 100.0
    case METER = 1000.0
}


extension SCNVector3{
    
    var length: SCNFloat{ sqrt(SCNVector3.dotProduct(v1:self,v2:self)) }
    
    init(translation matrix: matrix_float4x4) {
        self.init(matrix.columns.3.x, matrix.columns.3.y, matrix.columns.3.z)
    }
    
    func zero() -> Bool{
        return (x == 0.0 && y == 0.0 && z == 0.0)
    }
    
    func sub(_ v2:SCNVector3) -> SCNVector3{
        return SCNVector3(x: x - v2.x,
                          y: y - v2.y,
                          z: z - v2.z)
    }
    
    func add(_ v2:SCNVector3) -> SCNVector3{
        return SCNVector3(x: x + v2.x,
                          y: y + v2.y,
                          z: z + v2.z)
    }
    
    func mult(_ k:SCNFloat) -> SCNVector3{
        return SCNVector3(x: x * k,
                          y: y * k,
                          z: z * k)
    }
    
    func div(_ k:SCNFloat) -> SCNVector3{
        return SCNVector3(x: x / k,
                          y: y / k,
                          z: z / k)
    }

    func norm() -> SCNVector3{
        let invL = SCNFloat( 1.0 / length)
        return SCNVector3(x: x * invL,
                          y: y * invL,
                          z: z * invL)
    }
    
    func normalise() -> SCNVector3{
        let l = length
        return l == 0.0 ? SCNVector3() : SCNVector3(x: x / l,
                                                    y: y / l,
                                                    z: z / l)
    }
           
    func normalize() -> SCNVector3{
        let xxyyzz = x*x + y*y + z*z
        
        let invlength = 1.0 / sqrt(xxyyzz)
        return SCNVector3(x: x * invlength,
                          y: y * invlength,
                          z: z * invlength)
    }
    
    func dotProduct(v2:SCNVector3) -> SCNFloat{
        return x * v2.x + y * v2.y + z * v2.z
    }
    
    func dot() -> SCNFloat{
        return x*x + y*y + z*z
     }
    
    func directionCosine() -> SCNVector3{
        let PX = sqrt(pow(x,2) + pow(y,2) + pow(z,2))
        return SCNVector3(x/PX, y/PX, z/PX)
     }
    
    func crossProduct(v2:SCNVector3) -> SCNVector3{
         return SCNVector3(x: y * v2.z - z * v2.y,
                           y: z * v2.x - x * v2.z,
                           z: x * v2.y - y * v2.x)
    }
        
    func mulEqualF(a:SCNFloat) -> SCNVector3{
         return SCNVector3(x: x * a,
                           y: y * a,
                           z: z * a)
    }
    
    func distance(to destination: SCNVector3,convert to:ScnVectorDistance = .DEFAULT) -> SCNFloat {
        let dx = destination.x - x
        let dy = destination.y - y
        let dz = destination.z - z
        var distance = SCNFloat(sqrt(dx*dx + dy*dy + dz*dz))
        distance *= to.rawValue
        return abs(distance)
    }
    
    static func dotProduct(v1:SCNVector3,v2:SCNVector3) -> SCNFloat{
        return v1.x*v2.x + v1.y*v2.y + v1.z*v2.z
    }
    
    static func distanceBetweenTwoPoints(n1: SCNVector3, n2:SCNVector3) -> SCNFloat {
        return n1.distance(to: n2,convert: .CENTIMETER)
    }
    
    static func angleBetweenTwoPoints(n1:SCNVector3, n2:SCNVector3) -> SCNFloat {
        let dp = SCNVector3.dotProduct(v1: n1, v2: n2)
        let asqrt = sqrt(n1.dot())
        let bsqrt = sqrt(n2.dot())
        let theta = (dp/asqrt)*bsqrt
        let radians = acos(theta)
        let angle = radians * (180.0/SCNFloat.pi)
        return angle
    }
    
    static func radiansBetweenTwoPoints(n1:SCNVector3, n2:SCNVector3) -> SCNFloat {
        let p1 = n1.z > n2.z ? n2 : n1
        let p2 = n1.z > n2.z ? n1 : n2
        
        let x0 = pow(p2.x-p1.x, 2)
        let y0 = pow(p2.y-p1.y, 2)
        let run = sqrt(x0+y0)
        let rise = p2.z-p1.z
        let slope = rise/run
        return slope
    }
    
    static func directionRatioBetween(n1:SCNVector3, n2:SCNVector3) -> SCNVector3 {
        return n2.sub(n1)
    }
    
    static func angleBetweenThreePoints(n1:SCNVector3, n2:SCNVector3,n3:SCNVector3) -> SCNFloat {
        let v1 = SCNVector3(n1.x - n2.x, n1.y - n2.y, n1.z - n2.z)
        let v2 = SCNVector3(n3.x - n2.x, n3.y - n2.y, n3.z - n2.z)
        let dot = SCNVector3.dotProduct(v1: v1.norm(), v2: v2.norm())
        let radians = acos(dot)
        let angle = radians * (180.0/SCNFloat.pi)
        return angle
    }
    
    static func angleOfLine(v1:SCNVector3, v2:SCNVector3) -> SCNFloat{
      let d = SCNVector3.diff(v1:v1,v2:v2)
      let theta = atan2(d.z, d.x)
      return SCNFloat.pi - theta
    }
    
    static func distanceOfLine(v1: SCNVector3,v2: SCNVector3,convert to:ScnVectorDistance = .DEFAULT) -> SCNFloat {
        let dx = v1.x - v2.x
        let dy = v1.y - v2.y
        let dz = v1.z - v2.z
        var distance = SCNFloat(sqrt(dx*dx + dy*dy + dz*dz))
        distance *= to.rawValue
    
        return abs(distance)
    }
    
    static func centerOfVector(v1:SCNVector3, v2:SCNVector3) -> SCNVector3{
        return SCNVector3((v1.x + v2.x) / 2.0, (v1.y + v2.y) / 2.0 , (v1.z + v2.z) / 2.0)
    }
    
    static func diff(v1:SCNVector3,v2:SCNVector3) ->SCNVector3{
        if v1.x > v2.x {
            return SCNVector3(v2.x - v1.x, v2.y - v1.y, v2.z - v1.z)
        }
        else{
           return SCNVector3(v1.x - v2.x, v1.y - v2.y, v1.z - v2.z)
        }
     }
    
    static func eulerAngles(v1:SCNVector3, v2:SCNVector3) -> SCNVector3{
        let w = SCNVector3.diff(v1:v1, v2:v2)
        let h = hypot(w.x, w.z)
        return SCNVector3(x: atan2(h, w.y),y: atan2(w.x, w.z),z: 0)
    }
    
}

extension SCNFloat {
    func roundTo(places: Int) -> SCNFloat {
        let divisor = pow(10.0, SCNFloat(places))
        return (self * divisor).rounded() / divisor
    }
}

