//
//  Vector.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-09-09.
//

import SwiftUI
import SceneKit

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
     
    static func dotProduct(v1:SCNVector3,v2:SCNVector3) -> SCNFloat{
        return v1.x * v2.x + v1.y * v2.y + v1.z * v2.z
    }
    
    static func angleBetweenTwoPointsToHorizontalPlane(n1:SCNVector3, n2:SCNVector3) -> Float {
        let p2Hor = SCNVector3(n2.x, n1.y, n2.z)
        let p1ToP2Norm = n2.sub(n1).normalise()
        let p1ToP2HorNorm = p2Hor.sub(n1).normalise()
        let dotProduct = p1ToP2Norm.dotProduct(v2: p1ToP2HorNorm)
        return acos(dotProduct)
        /*
         We can find angle between 2 vectors according the dot production.
         angle = arccos ( a * b / |a| * |b| );
         where:
         a * b = ax * bx + ay * by + az * bz
         |a| = sqrt( ax * ax + ay * ay + az * az )
         |b| = sqrt( bx * bx + by * by + bz * bz )
         
         
         def GetAngle(self, a, b):
             length = math.sqrt((a.x - b.x)**2 + (a.y - b.y)**2 + (a.z - b.z)**2)
             rise = b.y - a.y
             run = math.sqrt((length**2) - (rise**2))
             angle = math.degrees(math.atan(rise/run))
             return angle
         */
    }
    
    static func angleBetweenThreePointsToHorizontalPlane(n1:SCNVector3, n2:SCNVector3,n3:SCNVector3) -> Float {
        let v1 = SCNVector3(n1.x - n2.x, n1.y - n2.y, n1.z - n2.z)
        let v2 = SCNVector3(n3.x - n2.x, n3.y - n2.y, n3.z - n2.z)
        
        let dot = SCNVector3.dotProduct(v1: v1.norm(), v2: v2.norm())
        
        //N1: SCNVector3(x: -0.17147546, y: -0.40633973, z: 0.026907394)
        //N2: SCNVector3(x: -0.1569796, y: -0.38139328, z: -0.043307792)
        //N3: SCNVector3(x: -0.02777277, y: -0.382627, z: -0.022403035)
        return acos(dot)
    }
    
    
}
