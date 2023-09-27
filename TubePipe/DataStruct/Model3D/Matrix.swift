//
//  Matrix.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-09-09.
//

import SwiftUI
import SceneKit

let EPSILON:SCNFloat = SCNFloat(0.00001)

class Mat4x4{
    var m:[SCNFloat] = [
        SCNFloat(0.0),SCNFloat(0.0),SCNFloat(0.0),SCNFloat(0.0),
        SCNFloat(0.0),SCNFloat(0.0),SCNFloat(0.0),SCNFloat(0.0),
        SCNFloat(0.0),SCNFloat(0.0),SCNFloat(0.0),SCNFloat(0.0),
        SCNFloat(0.0),SCNFloat(0.0),SCNFloat(0.0),SCNFloat(0.0)]
    
    
    func lookAt(target:SCNVector3){
        let position = SCNVector3(x:m[12],y:m[13],z:m[14])
        var forward = target.sub(position)
        
        forward = forward.norm()
        
        var up: SCNVector3
        if(SCNFloat(abs(forward.x)) < EPSILON && SCNFloat(abs(forward.z)) < EPSILON){
            if(forward.y > 0.0){
                up = SCNVector3(x:0.0,y:0.0,z:-1.0)
            }
            else{
                up = SCNVector3(x:0.0,y:0.0,z:1.0)
            }
        }
        
        else{
            up = SCNVector3(x:0.0,y:1.0,z:0.0)
        }
            
        var left = up.crossProduct(v2: forward)
        
        left = left.norm()
        
        up = forward.crossProduct(v2:left)
        setColumn(row:0,v:left)
        setColumn(row:1,v:up)
        setColumn(row:2,v:forward)
    }
    
    func translate(v:SCNVector3){
        translate(x: v.x, y: v.y, z: v.z)
    }
    
    func translate(x:SCNFloat,y:SCNFloat,z:SCNFloat){
        m[0] += m[3] * x;   m[4] += m[7] * x;   m[8]  += m[11] * x;   m[12]  += m[15] * x;
        m[1] += m[3] * y;   m[5] += m[7] * y;   m[9]  += m[11] * y;   m[13]  += m[15] * y;
        m[2] += m[3] * z;   m[6] += m[7] * z;   m[10] += m[11] * z;   m[14]  += m[15] * z;
    }

    func setColumn(row:Int,v:SCNVector3){
        m[row * 4 ] = v.x
        m[row * 4 + 1] = v.y
        m[row * 4 + 2] = v.z
    }
     
    func multVec3d(_ v:SCNVector3) -> SCNVector3{
        return SCNVector3(x:m[0] * v.x + m[4] * v.y + m[8]  * v.z + m[12],
                          y:m[1] * v.x + m[5] * v.y + m[9]  * v.z + m[13],
                          z:m[2] * v.x + m[6] * v.y + m[10] * v.z + m[14])
    }
       
    static func makeIdentity() -> Mat4x4{
        let matrix = Mat4x4()
        matrix.m[0] = 1.0
        matrix.m[5] = 1.0
        matrix.m[10] = 1.0
        matrix.m[15] = 1.0
        return matrix
    }
        
}
