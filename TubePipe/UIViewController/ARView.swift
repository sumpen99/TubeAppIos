//
//  ARView.swift
//  TubePipe
//
//  Created by fredrik sundström on 2024-01-11.
//

//https://blog.devgenius.io/implementing-ar-in-swiftui-without-storyboards-ec529ace7ab2
//https://stackoverflow.com/questions/64139575/is-it-possible-to-use-swiftui-for-ui-in-an-ar-app-using-scenekit
//https://stackoverflow.com/questions/64896064/can-i-use-zoom-with-arview
//https://github.com/ClearCut3000/ARDrawing/blob/master1/ARKit-Drawing/ViewController.swift
//https://www.gfrigerio.com/arkit-in-a-swiftui-app/
//https://www.gfrigerio.com/arkit-in-a-swiftui-app/

import ARKit
import SwiftUI

extension UIColor {
    static let planeColor = UIColor(named: "planeColor")!
}

class ARPlane: SCNNode {
    
    let meshNode: SCNNode
    let extentNode: SCNNode
    var classificationNode: SCNNode?
    
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
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
    }
}

struct TubeARView: UIViewRepresentable {
    typealias UIViewType = ARSCNView
    typealias Context = UIViewRepresentableContext<TubeARView>
    let arCoordinator:ARCoordinator
    
    func makeUIView(context: Context) -> UIViewType {
        let arSCNView = ARSCNView(frame: .zero)
        arCoordinator.setARView(arSCNView)
        return arSCNView
   }
    
    func updateUIView(_ arSCNView: ARSCNView, context: Context) {
        debugLog(object: "updateARView: \(arSCNView.debugDescription)")
    }
    
    static func dismantleUIView(_ arSCNView: ARSCNView, coordinator: ARCoordinator) {
        coordinator.pauseSession()
        debugLog(object: "dismantleARView: \(arSCNView.debugDescription)")
    }
    
    func makeCoordinator() -> ARCoordinator {
        return arCoordinator
    }
    
}

class ARCoordinator: NSObject, ARSCNViewDelegate,ObservableObject {
    var arSCNView: ARSCNView?
    var nodeList:[SCNNode] = []
    
    func setARView(_ arSCNView: ARSCNView) {
        self.arSCNView = arSCNView
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal,.vertical]
        configuration.isLightEstimationEnabled = true
      
        arSCNView.autoenablesDefaultLighting = true
        arSCNView.session.run(configuration,options: [.resetTracking, .removeExistingAnchors])
        
        arSCNView.delegate = self
        arSCNView.scene = SCNScene()
        addTapGesture()
    }
   
    func addTapGesture(){
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didRecieveTapGesture(_:)))
        arSCNView?.addGestureRecognizer(tapGestureRecognizer)
    }
     
    func pauseSession(){
        self.arSCNView?.session.pause()
    }

    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        debugLog(object: "Rootnode childrens: \(self.arSCNView?.scene.rootNode.childNodes.count)")
        if let planeAnchor = anchor as? ARPlaneAnchor{
            debugLog(object: "<-- FOUND PLANE -->")
            //let plane = ARPlane(anchor:planeAnchor,in: arSCNView)
            //node.addChildNode(plane)
        } else {
            debugLog(object: "<-- TOUCH NODE -->")
            //let sphereNode = generateSphereNode()
            //node.addChildNode(sphereNode)
            //clearNodeList()
            //nodeList.append(node)
            //calculateDistanceBetweenTwoNodes()
        }
        //let plane = ARPlane(anchor:planeAnchor,in: arSCNView)
        //node.addChildNode(plane)
        //guard !(anchor is ARPlaneAnchor) else { return }
        //let sphereNode = generateSphereNode()
        /*DispatchQueue.main.async {
            node.addChildNode(sphereNode)
            debugLog(object: "Rootnode childrens: \(self.arSCNView.scene.rootNode.childNodes.count)")
       }*/
    }

    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        //debugLog(object: "renderer 2")
        // do some node transform stuff
        //...
        //trackDistance()
    }
    
    
    @objc
    func didRecieveTapGesture(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: arSCNView)
        if let query = arSCNView?.raycastQuery(from: location,
                                              allowing: .estimatedPlane,
                                              alignment: .any),
              let hitTestResult = arSCNView?.session.raycast(query).first{
                   
                    addCircle(raycastResult: hitTestResult)
                  //let anchor = ARAnchor(transform: hitTestResult.worldTransform)
                  //arSCNView.session.add(anchor: anchor)
        }
    }
    
    func addCircle(raycastResult: ARRaycastResult) {
        let circleNode = createCircle(fromRaycastResult: raycastResult)
        clearNodeList()
        arSCNView?.scene.rootNode.addChildNode(circleNode)
        nodeList.append(circleNode)
        calculateDistanceBetweenTwoNodes()
     }
    
    func createCircle(fromRaycastResult result:ARRaycastResult) -> SCNNode {
        let circleGeometry = SCNSphere(radius: 0.005)
        
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.systemBlue
        
        circleGeometry.materials = [material]
        
        let circleNode = SCNNode(geometry: circleGeometry)
        circleNode.simdWorldTransform = result.worldTransform
        
        return circleNode
    }
            
    func calculateDistanceBetweenTwoNodes(){
        if(nodeList.count < 2){ return }
        let distance = calculateDistance(firstNode: nodeList[0], secondNode: nodeList[1])
        debugLog(object: "distance " + String(format: "%.2f cm", distance))
    }
    
    func clearNodeList(){
        if(nodeList.count < 2){ return }
        for node in nodeList {
            node.removeFromParentNode()
        }
        nodeList.removeAll()
    }
    
    func calculateDistance(firstNode: SCNNode, secondNode:SCNNode) -> Float {
        let firstPosition = firstNode.position
        let secondPosition = secondNode.position
        var distance:Float = sqrt(
            pow(secondPosition.x - firstPosition.x, 2) +
                pow(secondPosition.y - firstPosition.y, 2) +
                pow(secondPosition.z - firstPosition.z, 2)
        )
        
        distance *= 100 // convert in cm
        return abs(distance)
    }
    
    func generateSphereNode() -> SCNNode {
        let dot = SCNBox(width: 0.01, height: 0.01, length: 0.01, chamferRadius: 0.01)
        dot.firstMaterial?.diffuse.contents = UIColor.blue.withAlphaComponent(1.0)
        let node = SCNNode(geometry: dot)
        
        return node
    }
   
    func sessionWasInterrupted(_ session: ARSession) {}
    func sessionInterruptionEnded(_ session: ARSession) {}
    //func sessionShouldAttemptRelocalization(_ session: ARSession) -> Bool {}
    func session(_ session: ARSession, didFailWithError error: Error){}
    func session(_ session: ARSession, cameraDidChangeTrackingStatecamera: ARCamera) {}
    func session(_ session: ARSession, didChange geoTrackingStatus: ARGeoTrackingStatus) {}
    func session(_ session: ARSession, didOutputCollaborationData data: ARSession.CollaborationData) {}
    func session(_ session: ARSession, didOutputAudioSampleBuffer audioSampleBuffer: CMSampleBuffer) {}
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {}
}
extension SCNVector3 {
    func distance(to destination: SCNVector3) -> CGFloat {
        let dx = destination.x - x
        let dy = destination.y - y
        let dz = destination.z - z
        return CGFloat(sqrt(dx*dx + dy*dy + dz*dz))
    }
}

@available(iOS 12.0, *)
extension ARPlaneAnchor.Classification {
    var description: String {
        switch self {
        case .wall:
            return "Wall"
        case .floor:
            return "Floor"
        case .ceiling:
            return "Ceiling"
        case .table:
            return "Table"
        case .seat:
            return "Seat"
        case .none(.unknown):
            return "Unknown"
        default:
            return ""
        }
    }
}

extension SCNNode {
    func centerAlign() {
        let (min, max) = boundingBox
        let extents = SIMD3<Float>(max) - SIMD3<Float>(min)
        simdPivot = float4x4(translation: ((extents / 2) + SIMD3<Float>(min)))
    }
}

extension float4x4 {
    init(translation vector: SIMD3<Float>) {
        self.init(SIMD4<Float>(1, 0, 0, 0),
                  SIMD4<Float>(0, 1, 0, 0),
                  SIMD4<Float>(0, 0, 1, 0),
                  SIMD4<Float>(vector.x, vector.y, vector.z, 1))
    }
}

/*
struct TubeARView: UIViewRepresentable {
    typealias UIViewType = ARSCNView
    typealias Context = UIViewRepresentableContext<TubeARView>
    let scene: SCNScene
    
    func makeUIView(context: Context) -> UIViewType {
        context.coordinator.setBase()
        context.coordinator.addTapGesture()
        context.coordinator.startSession()
        //context.coordinator.arSCNView.scene = scene
        context.coordinator.arSCNView.scene = SCNScene()
        //context.coordinator.arSCNView.scene.rootNode.addChildNode(context.coordinator.parentNode)
        return context.coordinator.arSCNView
    }
    
    func updateUIView(_ arSCNView: ARSCNView, context: Context) {
        debugLog(object: "updateARView: \(arSCNView.debugDescription)")
    }
    
    static func dismantleUIView(_ arSCNView: ARSCNView, coordinator: Coordinator) {
        coordinator.pauseSession()
        debugLog(object: "dismantleARView: \(arSCNView.debugDescription)")
    }
    
    
    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }

    class Coordinator: NSObject, ARSCNViewDelegate {
        let arSCNView: ARSCNView = ARSCNView(frame: .zero)
        var nodeList:[SCNNode] = []
        
        func setBase(){
            //arSCNView.backgroundColor = UIColor.clear
            //arSCNView.allowsCameraControl = true
            arSCNView.autoenablesDefaultLighting = true
            //arSCNView.showsStatistics = true
        }
        
        func addTapGesture(){
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didRecieveTapGesture(_:)))
            arSCNView.addGestureRecognizer(tapGestureRecognizer)
        }
        
        func startSession(){
            //guard ARFaceTrackingConfiguration.isSupported else { return }
            //let configuration = ARFaceTrackingConfiguration()
            //arView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
            let configuration = ARWorldTrackingConfiguration()
            configuration.planeDetection = [.horizontal,.vertical]
            configuration.isLightEstimationEnabled = true
            //configuration.worldAlignment = .camera
            //configuration.planeDetection = .horizontal
            arSCNView.session.run(configuration,options: [.resetTracking, .removeExistingAnchors])
            arSCNView.delegate = self
        }
     
        func pauseSession(){
            self.arSCNView.session.pause()
        }

        func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
            debugLog(object: "Rootnode childrens: \(self.arSCNView.scene.rootNode.childNodes.count)")
            if let planeAnchor = anchor as? ARPlaneAnchor{
                debugLog(object: "<-- FOUND PLANE -->")
                //let plane = ARPlane(anchor:planeAnchor,in: arSCNView)
                //node.addChildNode(plane)
            } else {
                debugLog(object: "<-- TOUCH NODE -->")
                //let sphereNode = generateSphereNode()
                //node.addChildNode(sphereNode)
                //clearNodeList()
                //nodeList.append(node)
                //calculateDistanceBetweenTwoNodes()
            }
            //let plane = ARPlane(anchor:planeAnchor,in: arSCNView)
            //node.addChildNode(plane)
            //guard !(anchor is ARPlaneAnchor) else { return }
            //let sphereNode = generateSphereNode()
            /*DispatchQueue.main.async {
                node.addChildNode(sphereNode)
                debugLog(object: "Rootnode childrens: \(self.arSCNView.scene.rootNode.childNodes.count)")
           }*/
        }

        func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
            //debugLog(object: "renderer 2")
            // do some node transform stuff
            //...
            //trackDistance()
        }
        
        
        @objc
        func didRecieveTapGesture(_ sender: UITapGestureRecognizer) {
            let location = sender.location(in: arSCNView)
            if let query = arSCNView.raycastQuery(from: location,
                                                  allowing: .estimatedPlane,
                                                  alignment: .any),
                  let hitTestResult = arSCNView.session.raycast(query).first{
                       
                        addCircle(raycastResult: hitTestResult)
                      //let anchor = ARAnchor(transform: hitTestResult.worldTransform)
                      //arSCNView.session.add(anchor: anchor)
            }
        }
        
        func addCircle(raycastResult: ARRaycastResult) {
            let circleNode = createCircle(fromRaycastResult: raycastResult)
            if nodeList.count >= 2 {
                for node in nodeList {
                    node.removeFromParentNode()
                }
                nodeList.removeAll()
            }
            
            arSCNView.scene.rootNode.addChildNode(circleNode)
            nodeList.append(circleNode)
            
            if nodeList.count == 2 {
                let distance = calculateDistance(firstNode: nodeList[0], secondNode: nodeList[1])
                debugLog(object: "distance " + String(format: "%.2f cm", distance))
            }
         }
        
        func createCircle(fromRaycastResult result:ARRaycastResult) -> SCNNode {
            let circleGeometry = SCNSphere(radius: 0.005)
            
            let material = SCNMaterial()
            material.diffuse.contents = UIColor.systemBlue
            
            circleGeometry.materials = [material]
            
            let circleNode = SCNNode(geometry: circleGeometry)
            circleNode.simdWorldTransform = result.worldTransform
            
            return circleNode
        }
                
        func calculateDistanceBetweenTwoNodes(){
            if(nodeList.count < 2){ return }
            let distance = calculateDistance(firstNode: nodeList[0], secondNode: nodeList[1])
            debugLog(object: "distance = \(distance)")
        }
        
        func clearNodeList(){
            if(nodeList.count < 2){ return }
            for node in nodeList {
                node.removeFromParentNode()
            }
        }
        
        func calculateDistance(firstNode: SCNNode, secondNode:SCNNode) -> Float {
            let firstPosition = firstNode.position
            let secondPosition = secondNode.position
            var distance:Float = sqrt(
                pow(secondPosition.x - firstPosition.x, 2) +
                    pow(secondPosition.y - firstPosition.y, 2) +
                    pow(secondPosition.z - firstPosition.z, 2)
            )
            
            distance *= 100 // convert in cm
            return abs(distance)
        }
        
        func generateSphereNode() -> SCNNode {
            let dot = SCNBox(width: 0.01, height: 0.01, length: 0.01, chamferRadius: 0.01)
            dot.firstMaterial?.diffuse.contents = UIColor.blue.withAlphaComponent(1.0)
            let node = SCNNode(geometry: dot)
            
            return node
        }
       
        func sessionWasInterrupted(_ session: ARSession) {}
        func sessionInterruptionEnded(_ session: ARSession) {}
        //func sessionShouldAttemptRelocalization(_ session: ARSession) -> Bool {}
        func session(_ session: ARSession, didFailWithError error: Error){}
        func session(_ session: ARSession, cameraDidChangeTrackingStatecamera: ARCamera) {}
        func session(_ session: ARSession, didChange geoTrackingStatus: ARGeoTrackingStatus) {}
        func session(_ session: ARSession, didOutputCollaborationData data: ARSession.CollaborationData) {}
        func session(_ session: ARSession, didOutputAudioSampleBuffer audioSampleBuffer: CMSampleBuffer) {}
        func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {}
    }
      
}
extension SCNVector3 {
    func distance(to destination: SCNVector3) -> CGFloat {
        let dx = destination.x - x
        let dy = destination.y - y
        let dz = destination.z - z
        return CGFloat(sqrt(dx*dx + dy*dy + dz*dz))
    }
}

@available(iOS 12.0, *)
extension ARPlaneAnchor.Classification {
    var description: String {
        switch self {
        case .wall:
            return "Wall"
        case .floor:
            return "Floor"
        case .ceiling:
            return "Ceiling"
        case .table:
            return "Table"
        case .seat:
            return "Seat"
        case .none(.unknown):
            return "Unknown"
        default:
            return ""
        }
    }
}

extension SCNNode {
    func centerAlign() {
        let (min, max) = boundingBox
        let extents = SIMD3<Float>(max) - SIMD3<Float>(min)
        simdPivot = float4x4(translation: ((extents / 2) + SIMD3<Float>(min)))
    }
}

extension float4x4 {
    init(translation vector: SIMD3<Float>) {
        self.init(SIMD4<Float>(1, 0, 0, 0),
                  SIMD4<Float>(0, 1, 0, 0),
                  SIMD4<Float>(0, 0, 1, 0),
                  SIMD4<Float>(vector.x, vector.y, vector.z, 1))
    }
}
*/
