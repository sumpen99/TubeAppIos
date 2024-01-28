//
//  ARPlane.swift
//  TubePipe
//
//  Created by fredrik sundström on 2024-01-27.
//

import ARKit
import SwiftUI

class ARPlane: SCNNode {
    var planeGeometry: SCNBox?
    var anchor: ARPlaneAnchor?
    //let meshNode: SCNNode
    //let extentNode: SCNNode
    //var classificationNode: SCNNode?

    init(anchor:ARPlaneAnchor){
        super.init()
        let width = CGFloat(anchor.planeExtent.width)
        let length = CGFloat(anchor.planeExtent.height)
        let planeHeight = 0.01 as CGFloat
        self.planeGeometry = SCNBox(width: width, height: planeHeight, length: length, chamferRadius: 0.0)
        
        let material = SCNMaterial()
        //let image = UIImage(named:"grid")
        material.diffuse.contents = UIColor.planeColor
        
        let transparentMaterial = SCNMaterial()
        transparentMaterial.diffuse.contents = UIColor.white.withAlphaComponent(0.0)
        self.planeGeometry?.materials = [transparentMaterial,transparentMaterial,transparentMaterial,transparentMaterial,material,transparentMaterial]
        let planeNode = SCNNode(geometry: self.planeGeometry)
        planeNode.position = SCNVector3(0,-planeHeight/2.0,0)
        self.addChildNode(planeNode)
        
        setTextureScale()
        
    }
    
    func updateWith(_ anchor:ARPlaneAnchor){
        if let planeGeometry = self.planeGeometry{
            planeGeometry.width = CGFloat(anchor.planeExtent.width)
            planeGeometry.length = CGFloat(anchor.planeExtent.height)
            position = SCNVector3(anchor.planeExtent.width,0,anchor.planeExtent.height)
            setTextureScale()
        }
   
    }
    
    func setTextureScale(){
        if let width = self.planeGeometry?.width,
           let length = self.planeGeometry?.length,
           let material = self.planeGeometry?.materials[4]{
            material.diffuse.contentsTransform = SCNMatrix4MakeScale(SCNFloat(width), SCNFloat(length), 1.0)
            material.diffuse.wrapS = .repeat
            material.diffuse.wrapT = .repeat
        }
        else{
            fatalError("PlaneGeometry not set")
        }
     }
    
    

    /*
   init(anchor: ARPlaneAnchor, in sceneView: ARSCNView) {
        // Create a mesh to visualize the estimated shape of the plane.
        guard let meshGeometry = ARSCNPlaneGeometry(device: sceneView.device!)
            else { fatalError("Can't create plane geometry") }
        meshGeometry.update(from: anchor.geometry)
        meshNode = SCNNode(geometry: meshGeometry)
        
        // Create a node to visualize the plane's bounding rectangle.
       let extentPlane: SCNPlane = SCNPlane(width: CGFloat(anchor.planeExtent.width), height: CGFloat(anchor.planeExtent.height))
        extentNode = SCNNode(geometry: extentPlane)
        extentNode.simdPosition = anchor.center
        
        // `SCNPlane` is vertically oriented in its local coordinate space, so
        // rotate it to match the orientation of `ARPlaneAnchor`.
        extentNode.eulerAngles.x = -.pi / 2

        super.init()

        self.setupMeshVisualStyle()
        self.setupExtentVisualStyle()

        // Add the plane extent and plane geometry as child nodes so they appear in the scene.
        addChildNode(meshNode)
        addChildNode(extentNode)
        
        // Display the plane's classification, if supported on the device
        if #available(iOS 12.0, *), ARPlaneAnchor.isClassificationSupported {
            let classification = anchor.classification.description
            let textNode = self.makeTextNode(classification)
            classificationNode = textNode
            // Change the pivot of the text node to its center
            textNode.centerAlign()
            // Add the classification node as a child node so that it displays the classification
            extentNode.addChildNode(textNode)
        }
    }
     private func setupMeshVisualStyle() {
         // Make the plane visualization semitransparent to clearly show real-world placement.
         meshNode.opacity = 0.25
         
         // Use color and blend mode to make planes stand out.
         guard let material = meshNode.geometry?.firstMaterial
             else { fatalError("ARSCNPlaneGeometry always has one material") }
         material.diffuse.contents = UIColor.planeColor
     }
     
     private func setupExtentVisualStyle() {
         // Make the extent visualization semitransparent to clearly show real-world placement.
         extentNode.opacity = 0.6

         guard let material = extentNode.geometry?.firstMaterial
             else { fatalError("SCNPlane always has one material") }
         
         material.diffuse.contents = UIColor.planeColor

         // Use a SceneKit shader modifier to render only the borders of the plane.
         guard let path = Bundle.main.path(forResource: "wireframe_shader", ofType: "metal", inDirectory: "Assets.scnassets")
             else { fatalError("Can't find wireframe shader") }
         do {
             let shader = try String(contentsOfFile: path, encoding: .utf8)
             material.shaderModifiers = [.surface: shader]
         } catch {
             fatalError("Can't load wireframe shader: \(error)")
         }
     }
     
     private func makeTextNode(_ text: String) -> SCNNode {
         let textGeometry = SCNText(string: text, extrusionDepth: 1)
         textGeometry.font = UIFont(name: "Futura", size: 75)

         let textNode = SCNNode(geometry: textGeometry)
         // scale down the size of the text
         textNode.simdScale = SIMD3<Float>(repeating:0.0005)
         
         return textNode
     }*/
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
