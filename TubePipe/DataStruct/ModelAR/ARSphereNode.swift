//
//  ARSpahereNode.swift
//  TubePipe
//
//  Created by fredrik sundström on 2024-02-11.
//

import SwiftUI
import ARKit

class ARSphereNode:SCNNode{
    convenience init(position:SCNVector3){
        let sphereGeometry = SCNSphere(radius: 0.003)
        sphereGeometry.firstMaterial?.diffuse.contents = UIColor.white.withAlphaComponent(1.0)
        sphereGeometry.firstMaterial?.lightingModel = .constant
        sphereGeometry.firstMaterial?.isDoubleSided = true
        self.init(geometry: sphereGeometry)
        self.position = position
    
    }
    
    init(geometry: SCNGeometry) {
        super.init()
        self.geometry = geometry
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
   
}
