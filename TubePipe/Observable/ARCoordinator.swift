//
//  ARCoordinator.swift
//  TubePipe
//
//  Created by fredrik sundström on 2024-01-21.
//
import SwiftUI
import ARKit

class ARCoordinator: NSObject, ARSCNViewDelegate,ObservableObject {
    var arSCNView: ARSCNView?
    var nodeList:[SCNNode] = []
    @Published var infoDistance:String = ""
    @Published var infoAngle:String = ""
    @Published var infoStatus:String = ""
    
    func setARView(_ arSCNView: ARSCNView) {
        self.arSCNView = arSCNView
        
        let configuration = ARWorldTrackingConfiguration()
        //configuration.planeDetection = [.horizontal,.vertical]
           
        configuration.isLightEstimationEnabled = true
      
        arSCNView.autoenablesDefaultLighting = true
        arSCNView.automaticallyUpdatesLighting = true
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
        let childrens = self.arSCNView?.scene.rootNode.childNodes.count ?? 0
        debugLog(object: "Rootnode childrens: \(childrens)")
        if let planeAnchor = anchor as? ARPlaneAnchor{
            debugLog(object: "<-- FOUND PLANE -->")
            //let plane = ARPlane(anchor:planeAnchor,in: arSCNView)
            //node.addChildNode(plane)
        } else {
            debugLog(object: "<-- TOUCH NODE -->")
            /*let sphereNode = generateSphereNode()
            DispatchQueue.main.async {
                node.addChildNode(sphereNode)
                self.nodeList.append(node)
                self.calculateDistance()
                self.calculateAngle()
           }*/
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
                    calculateDistance()
                    calculateAngle()
                    //let anchor = ARAnchor(transform: hitTestResult.worldTransform)
                    //arSCNView?.session.add(anchor: anchor)
        }
    }
    
    func addCircle(raycastResult: ARRaycastResult) {
        let circleNode = createCircle(fromRaycastResult: raycastResult)
        arSCNView?.scene.rootNode.addChildNode(circleNode)
        nodeList.append(circleNode)
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
            
    func calculateDistance(){
        if(nodeList.count <= 1){ return }
        var distance:Float = 0.0
        for i in (0..<nodeList.count-1){
            let n1 = nodeList[i].position,n2 = nodeList[i+1].position
            distance += calculateDistance(n1: n1, n2: n2)
        }
        infoDistance = "Distance " + String(format: "%.2f cm", distance)
    }
    
    func calculateAngle(){
        if(nodeList.count != 3){ return }
        let n1 = nodeList[0].position,n2 = nodeList[1].position,n3 = nodeList[2].position
        let angle2 = SCNVector3.angleBetweenTwoPointsToHorizontalPlane(n1: n1, n2: n3)
        let angle3 = SCNVector3.angleBetweenThreePointsToHorizontalPlane(n1: n1, n2: n2, n3: n3)
        debugLog(object: "deg 0 \(CGFloat(angle2))")
        debugLog(object: "deg 1 \(CGFloat(angle2).degToRad())")
        debugLog(object: "deg 2 \(CGFloat(angle2).radToDeg())")
        debugLog(object: "deg 3 \(CGFloat(angle3).radToDeg())")
        infoAngle = "Angle: " + String(format: "%.2f", angle3)
    }
    
    func clearNodeList(){
        for node in nodeList {
            node.removeFromParentNode()
        }
        nodeList.removeAll()
    }
    
    func calculateDistance(n1: SCNVector3, n2:SCNVector3) -> Float {
        var distance:Float = sqrt(
            pow(n2.x - n1.x, 2) +
                pow(n2.y - n1.y, 2) +
                pow(n2.z - n1.z, 2)
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
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        switch camera.trackingState {
        case ARCamera.TrackingState.notAvailable:
            infoStatus = "Not available"
        case ARCamera.TrackingState.limited(_):
            infoStatus = "Analyzing..."
        case ARCamera.TrackingState.normal:
            infoStatus = "Ready"
        }
     }
    func session(_ session: ARSession, didChange geoTrackingStatus: ARGeoTrackingStatus) {}
    func session(_ session: ARSession, didOutputCollaborationData data: ARSession.CollaborationData) {}
    func session(_ session: ARSession, didOutputAudioSampleBuffer audioSampleBuffer: CMSampleBuffer) {}
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
