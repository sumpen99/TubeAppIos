//
//  Vec3D.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-09-09.
//

import SwiftUI
import SceneKit

class Pipe{
    var path:[SCNVector3]
    var contour:[SCNVector3]
    var contours:[[SCNVector3]] = []
    var normals:[[SCNVector3]] = []
    var abort:Bool = false
    
    init(pathPoints:[SCNVector3],contourPoints:[SCNVector3]){
        path = pathPoints
        contour = contourPoints
        generateContours()
    }
     
    //MARK:  Get
    var pathCount:Int { path.count }
    var contourCount:Int { contour.count }
    var contoursCount:Int { contours.count }
    func getPathPoint(index:Int) -> SCNVector3{ return path[index] }
    func getContour(index:Int) -> [SCNVector3]{ return contours[index] }
    func getContourFirstLast() -> [[SCNVector3]?]{ return [contours.first,contours.last] }
    func getNormal(index:Int) -> [SCNVector3]{ return normals[index] }
    func clear_path(){ path.removeAll() }
       

    //MARK:  Class functions
    func generateContours(){
        contours.removeAll()
        normals.removeAll()
        if(pathCount < 1){ return }
        
        self.transformFirstContour()
        self.contours.append(contour)
        self.normals.append(computeContourNormal(pathIndex:0))
        
        let count = pathCount
        for i in stride(from:1,to:count,by:1){
            contours.append(projectContour(fromIndex:i-1,toIndex:i))
            normals.append(computeContourNormal(pathIndex:i))
            if abort{ break }
        }
   }
            
    func transformFirstContour(){
        let matrix = Mat4x4.makeIdentity()
        let vertexCount = contourCount
        if(pathCount > 0){
            if(pathCount > 1){
                matrix.lookAt(target: path[1].sub(path[0]))
            }
            matrix.translate(v:path[0])
            for i in (0..<vertexCount){
                contour[i] = matrix.multVec3d(contour[i])
            }
        }
    }
        
    func projectContour(fromIndex:Int,toIndex:Int) -> [SCNVector3]{
        var dir2:SCNVector3
        let dir1 = path[toIndex].sub(path[fromIndex])
        
        if(toIndex == pathCount-1){ dir2 = dir1 }
        else{ dir2 = path[toIndex+1].sub(path[toIndex]) }
       
        let normal = dir1.add(dir2)
      
        let plane = Plane(normal:normal,point:path[toIndex])
        
        let fromCountour = contours[fromIndex]
        
        var toContour:[SCNVector3] = []
        let count = fromCountour.count
        for i in (0..<count){
            let line = SCNLine(direction:dir1,point:fromCountour[i])
            if let p = plane.intersectLine(line){
                toContour.append(p)
            }
        }
        abort = toContour.count <= 0
        return toContour
    }
        
            
    func computeContourNormal(pathIndex:Int) -> [SCNVector3]{
        let contour = contours[pathIndex]
        let center = path[pathIndex]
        
        var contourNormal:[SCNVector3] = []
        
        for i in (0..<contour.count){
            let normal = contour[i].sub(center).norm()
            contourNormal.append(normal)
        }
        abort = contourNormal.count <= 0
        return contourNormal
    }
        
}


   


    
    
 
    
