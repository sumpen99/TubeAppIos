//
//  TextNode.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-09-22.
//

import SwiftUI
import SceneKit

enum AxisDirection{
    case AXIS_X
    case AXIS_Y
    case AXIS_Z
    
    
    static func colorByAxis(_ axis:AxisDirection) -> UIColor{
        switch axis{
        case .AXIS_X:   return UIColor.red
        case .AXIS_Y:   return UIColor.green
        case .AXIS_Z:   return UIColor.blue
        }
    }
    
    static func textByAxis(_ axis:AxisDirection) -> String{
        switch axis{
        case .AXIS_X:   return "X"
        case .AXIS_Y:   return "Y"
        case .AXIS_Z:   return "Z"
        }
    }
}

struct WorldAxisBox{
    
    static let mult:CGFloat = 1000.0
    
    static var defaultBox:SCNBox{
        SCNBox(width:           0.200 * CGFloat(WorldAxisBox.mult),
               height:          0.005 * CGFloat(WorldAxisBox.mult),
               length:          0.005 * CGFloat(WorldAxisBox.mult),
               chamferRadius:   0.001 * CGFloat(WorldAxisBox.mult))
    }
    
    static func defaultMaterial(color:UIColor) -> [SCNMaterial]{
        let material = SCNMaterial()
        material.lightingModel = .constant
        material.diffuse.contents = color
        return [ material ]
    }
}

struct WorldAxisDirection{
    let axisDirection:AxisDirection
    let extrusionDepth:CGFloat
    let transparency:CGFloat = 1.0
    
    var color:UIColor{
        AxisDirection.colorByAxis(axisDirection)
    }
    
    var text:String{
        AxisDirection.textByAxis(axisDirection)
    }
    
    var textPos:SCNVector3{
        let mult = SCNFloat(WorldAxisBox.mult)
        switch axisDirection {
        case .AXIS_X:   return SCNVector3(x: 0.100 * mult - 0.0075 * mult, y: 0.01 * mult, z: 0)
        case .AXIS_Y:   return SCNVector3(x: 0.100 * mult + 0.005 * mult, y: 0.005 * mult, z: 0)
        case .AXIS_Z:   return SCNVector3(x: 0.100 * mult - 0.0025 * mult, y: 0.01 * mult, z: 0.0025 * mult)
        }
    }
    
    var eulerAngleNode:SCNVector3{
        switch axisDirection {
        case .AXIS_X:   return SCNVector3(0, 0, 0)
        case .AXIS_Y:   return SCNVector3(0, 0, Float.pi/2)
        case .AXIS_Z:   return SCNVector3(0, -Float.pi/2, 0)
        }
    }
    
    var eulerAngleText:SCNVector3{
        switch axisDirection {
        case .AXIS_X:   return SCNVector3(0, 0, 0)
        case .AXIS_Y:   return SCNVector3(0, 0, -Float.pi/2)
        case .AXIS_Z:   return SCNVector3(0, Float.pi/2, 0)
        }
    }
    
    var addDirectionValue:SCNFloat{
        SCNFloat(0.1 * WorldAxisBox.mult)
    }
    
    var textNode:SCNNode{
        let textTodraw = SCNText(string: text, extrusionDepth: extrusionDepth)
        textTodraw.firstMaterial?.transparency = transparency
        textTodraw.firstMaterial?.diffuse.contents = color
        
        let textNode = SCNNode(geometry: textTodraw)
        textNode.eulerAngles = eulerAngleText
        textNode.position = textPos
        
        return textNode
    }
}
