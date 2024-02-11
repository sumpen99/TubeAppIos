//
//  ARLineNode.swift
//  TubePipe
//
//  Created by fredrik sundström on 2024-02-11.
//

import SwiftUI
import ARKit

class ARLineNode:SCNNode{
    convenience init(pos1: SCNVector3,
                     pos2:SCNVector3){
        let height = SCNVector3.distanceOfLine(v1: pos1, v2: pos2, convert: .DEFAULT)
        let z = SCNNode()
        z.eulerAngles.x = Float(CGFloat.pi / 2)
        
        let v2 = SCNNode()
        v2.position = pos2
        
        let cylinder = SCNCylinder(radius: 0.0003, height: CGFloat(height))
        cylinder.firstMaterial?.diffuse.contents = UIColor.white.withAlphaComponent(1.0)
        
        let nodeCylinder = SCNNode(geometry: cylinder )
        nodeCylinder.position.y = -height/2
        z.addChildNode(nodeCylinder)
         
        self.init()
        self.addChildNode(z)
        self.constraints = [SCNLookAtConstraint(target: v2)]
        self.position = pos1
    }
    
    override init() {
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
