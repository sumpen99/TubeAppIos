//
//  ArTextNode.swift
//  TubePipe
//
//  Created by fredrik sundström on 2024-02-11.
//
import SwiftUI
import ARKit

enum TextOrientation{
    case CENTER
    case POINT
    
}

class ARTextNode:SCNNode{
    var pos1:SCNVector3?
    var pos2:SCNVector3?
    var euler:SCNVector3?
    var textOrientation:TextOrientation?
    convenience init(pos1: SCNVector3,
                     pos2:SCNVector3,
                     orientation:TextOrientation,
                     euler:SCNVector3? = nil){
        let distance = SCNVector3.distanceOfLine(v1: pos1, v2: pos2, convert: .CENTIMETER)
        let text = String(format: "%.2f cm", distance)
        let textGeometry = SCNText(string: text, extrusionDepth: 1)
        textGeometry.font = UIFont.boldSystemFont(ofSize: 8)
        textGeometry.firstMaterial?.diffuse.contents = UIColor.white.withAlphaComponent(1.0)
        self.init(textGeometry: textGeometry)
        self.pos1 = pos1
        self.pos2 = pos2
        self.euler = euler
        self.textOrientation = orientation
    }
    
    convenience init(pos2:SCNVector3,
                     text:String,
                     orientation:TextOrientation,
                     euler:SCNVector3? = nil){
        let textGeometry = SCNText(string: text, extrusionDepth: 1)
        textGeometry.font = UIFont.boldSystemFont(ofSize: 8)
        textGeometry.firstMaterial?.diffuse.contents = UIColor.white.withAlphaComponent(1.0)
        self.init(textGeometry: textGeometry)
        self.pos2 = pos2
        self.euler = euler
        self.textOrientation = orientation
    }
    
    init(textGeometry: SCNText) {
        super.init()
        textGeometry.firstMaterial?.lightingModel = .constant
        textGeometry.firstMaterial?.isDoubleSided = true
        textGeometry.flatness = 0
        self.geometry = textGeometry
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initialize(){
        if let textOrientation = textOrientation{
            switch textOrientation{
            case .CENTER:
                centerAlign()
            case .POINT:
                pointAlign()
            }
        }
        
    }
    
    func centerAlign(){
        translatePivot()
        simdScale()
        centerPosition()
        eulerPosition()
        rotateRadians()
        shiftAction()
        clear()
    }
    
    func pointAlign(){
        simdScale()
        pointPosition()
        clear()
    }
    
    func translatePivot(){
        let min = boundingBox.min
        let max = boundingBox.max
        pivot = SCNMatrix4MakeTranslation(
            min.x + (max.x - min.x)/2,
            min.y + (max.y - min.y)/2,
            min.z + (max.z - min.z)/2
        )
    }
    
    func simdScale(){
        simdScale = SIMD3<Float>(repeating:0.0005)
    }
     
    func centerPosition(){
        if let pos1 = pos1,
           let pos2 = pos2{
            let center = SCNVector3.centerOfVector(v1: pos1, v2: pos2)
            position = center
            //position.z -= 0.002
        }
    }
    
    func pointPosition(){
        if let pos2 = pos2{
            position = pos2
            constraints = [SCNBillboardConstraint()]
        }
    }
    
    func eulerPosition(){
        if let euler = euler{
            eulerAngles = euler
        }
    }
    
    func rotateRadians(){
        if let pos1 = pos1,
           let pos2 = pos2{
            let radians = SCNVector3.angleOfLine(v1: pos1, v2: pos2)
            rotation = SCNVector4(0, 1, 0, radians)
        }
    }
    
    func shiftAction(){
        let action = SCNAction.rotateBy(x: -CGFloat(90).degToRad(), y: 0, z: 0, duration: 0)
        runAction(action)
    }
    
    func clear(){
        pos1 = nil
        pos2 = nil
        euler = nil
        textOrientation = nil
    }
}
