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
    
    static func angleBetweenThreePoints(n1:SCNVector3, n2:SCNVector3,n3:SCNVector3) -> SCNFloat {
        let v1 = SCNVector3(n1.x - n2.x, n1.y - n2.y, n1.z - n2.z)
        let v2 = SCNVector3(n3.x - n2.x, n3.y - n2.y, n3.z - n2.z)
        let dot = SCNVector3.dotProduct(v1: v1.norm(), v2: v2.norm())
        let radians = acos(dot)
        let angle = radians * (180.0/SCNFloat.pi)
        return angle
    }
    
    
}
