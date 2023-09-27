//
//  MeshCube.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-09-10.
//

import SwiftUI
import SceneKit

struct SCNTriangle{
    var p:[SCNVector3]
}

struct Obj{
    var vertices: [SCNVector3] = []
    var indices: [UInt16] = []
    var file:String = ""
    
    mutating func reset(){
        vertices.removeAll()
        indices.removeAll()
        file = ""
    }
}

class MeshCube{
    var vTris:[SCNTriangle] = []
    var obj:Obj = Obj()
     
    func reset(){
        vTris.removeAll()
        obj.reset()
    }
    
    func populateWithPipeVertices(_ vertices:[SCNVector3]){
        let stop = vertices.count - 2
        for i in (0..<stop){
            if i % 2 == 0{
                vTris.append(SCNTriangle(p: [vertices[i+1],vertices[i],vertices[i+2]]))
            }
            else{
                vTris.append(SCNTriangle(p: [vertices[i],vertices[i+1],vertices[i+2]]))
            }
        }
    }
    
    func populateWithCircleVertices(_ vertices:[SCNVector3],first:Int){
        let index = vTris.count
        for i in stride(from: 0, to: vertices.count - 2, by: 2){
            if first % 2 == 0{
                vTris.append(SCNTriangle(p: [vertices[i],SCNVector3(),vertices[i+1]]))
            }
            else{
                vTris.append(SCNTriangle(p: [vertices[i+1],SCNVector3(),vertices[i]]))
            }
        }
    
        let a = vTris[index].p[0]
        let b = vTris[index+1].p[0]
        let c = vTris[index+2].p[0]
        
        let ce = circleCenterXYZ(a: a, b: b, c: c)
        
        for i in stride(from: index, to: vTris.count, by: 1){
            vTris[i].p[1] = ce
        }
    }
    
    func circleCenterXYZ(a:SCNVector3,b:SCNVector3,c:SCNVector3) -> SCNVector3{
        let x = b.x-a.x
        if x == 0.0{
            let center = circleCenterXY(a:a,b:b,c:c)
            return SCNVector3(x:a.x, y:center.y, z:center.x)
        }
            
        let Cx = x
        let Cy = b.y-a.y
        let Cz = b.z-a.z
        
        let Bx = c.x-a.x
        let By = c.y-a.y
        let Bz = c.z-a.z
        
        let B2 = pow(a.x,2)-pow(c.x,2)+pow(a.y,2)-pow(c.y,2)+pow(a.z,2)-pow(c.z,2)
        let C2 = pow(a.x,2)-pow(b.x,2)+pow(a.y,2)-pow(b.y,2)+pow(a.z,2)-pow(b.z,2)

        let CByz = Cy*Bz-Cz*By
        let CBxz = Cx*Bz-Cz*Bx
        let CBxy = Cx*By-Cy*Bx
        
        let ZZ1 = -(Bz-Cz*Bx/Cx)/(By-Cy*Bx/Cx)
        let Z01 = -(B2-Bx/Cx*C2)/(2*(By-Cy*Bx/Cx))
        let ZZ2 = -(ZZ1*Cy+Cz)/Cx
        let Z02 = -(2*Z01*Cy+C2)/(2*Cx)

        let dz = -((Z02-a.x)*CByz-(Z01-a.y)*CBxz-a.z*CBxy)/(ZZ2*CByz-ZZ1*CBxz+CBxy)
        let dx = ZZ2*dz + Z02
        let dy = ZZ1*dz + Z01
        
        return SCNVector3(x:dx, y:dy, z:dz)
    }
        

    func circleCenterXY(a:SCNVector3,b:SCNVector3,c:SCNVector3) -> SCNVector3{
        let yDelta_a = b.y - a.y
        let xDelta_a = b.z - a.z
        let yDelta_b = c.y - b.y
        let xDelta_b = c.z - b.z
       
        let aSlope = yDelta_a/xDelta_a
        let bSlope = yDelta_b/xDelta_b
        let x = (aSlope*bSlope*(a.y - c.y) + bSlope*(a.z + b.z) - aSlope*(b.z+c.z) )/(2 * (bSlope-aSlope) )
        let y = -1*(x - (a.z+b.z)/2)/aSlope +  (a.y+b.y)/2
        return SCNVector3(x: x, y: y, z: 0.0)
    }
    
    func buildOBJType(){
        obj.vertices = vTris.enumerated().flatMap{ outerOffset, tri in
            tri.p.map{ $0 }
        }
        obj.indices = (0...obj.vertices.count-1).map { UInt16($0) }
    }
    
    func buildObjFile(){
        for i in stride(from: 0, to: obj.vertices.count, by: 3){
            let vert1 = obj.vertices[i]
            let vert2 = obj.vertices[i+1]
            let vert3 = obj.vertices[i+2]
            obj.file += "v \(vert1.x) \(vert1.y) \(vert1.z)\n"
            obj.file += "v \(vert2.x) \(vert2.y) \(vert2.z)\n"
            obj.file += "v \(vert3.x) \(vert3.y) \(vert3.z)\n"
        }
        for i in (0..<obj.vertices.count/3){
            let cnt = i*3
            obj.file += "f \(cnt) \(cnt+1) \(cnt+2)\n"
        }
    }
    
    func debugOBJFile(){
        debugLog(object: obj.file)
    }
}
