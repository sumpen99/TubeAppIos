//
//  ARCoordinator.swift
//  TubePipe
//
//  Created by fredrik sundström on 2024-01-21.
//
import SwiftUI
import ARKit

struct ArInfo{
    var distance:String = ""
    var angleTwo:String = ""
    var angleThree:String = ""
    var status:String = ""
    
    mutating func clearAngleText(){
        angleTwo = ""
        angleThree = ""
    }
    mutating func clearDistanceText(){ distance = "" }
    mutating func clearInfoStatusText(){ status = "" }
}

class ARCoordinator: NSObject, ARSCNViewDelegate,ObservableObject {
    var firstNode:SCNNode?
    var lineNode:SCNNode?
    var arSCNView: ARSCNView?
    var nodeList:[SCNNode] = []
    var planes = [ARPlaneAnchor:ARPlane]()
    @Published var info:ArInfo = ArInfo()
    
     
    func setARView(_ arSCNView: ARSCNView) {
        self.arSCNView = arSCNView
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]
        configuration.isLightEstimationEnabled = true
      
        arSCNView.autoenablesDefaultLighting = true
        arSCNView.automaticallyUpdatesLighting = true
        //arSCNView.showsStatistics = true
        //arSCNView.debugOptions = [ARSCNDebugOptions .showFeaturePoints,
        //                          ARSCNDebugOptions.showWorldOrigin]
        arSCNView.session.run(configuration,options: [.resetTracking, .removeExistingAnchors])
        
        arSCNView.delegate = self
        //arSCNView.scene = SCNScene()
        //addTapGesture()
    }
    
    func switchTo(scene newScene:SCNScene,allowCameraControl:Bool) async{
        DispatchQueue.main.async {
            if let arSCNView = self.arSCNView,
               let configuration = arSCNView.session.configuration{
                arSCNView.allowsCameraControl = allowCameraControl
                arSCNView.session.run(configuration)
                arSCNView.scene = newScene
            }
         }
    }
    
    func zoom(direction:Int){
        DispatchQueue.main.async {
            if let arSCNView = self.arSCNView{
                var zoom:SCNAction
                switch(direction){
                case 0:
                    let newX = arSCNView.scene.rootNode.boundingBox.min.x + arSCNView.scene.rootNode.boundingBox.max.x
                    zoom = SCNAction.move(by: SCNVector3(x: -newX*2, y: 0, z: 0), duration: 0)
                case 1:
                    let newY = arSCNView.scene.rootNode.boundingBox.min.y + arSCNView.scene.rootNode.boundingBox.max.y
                    zoom = SCNAction.move(by: SCNVector3(x: 0, y: -newY*2, z: 0), duration: 0)
                case 2:
                    let newZ = arSCNView.scene.rootNode.boundingBox.min.z + arSCNView.scene.rootNode.boundingBox.max.z
                    zoom = SCNAction.move(by: SCNVector3(x: 0, y: 0, z: -newZ*2), duration: 0)
                default:
                    return
                }
                arSCNView.scene.rootNode.runAction(zoom)
            }
        }
    }
    
    func kill() {
        DispatchQueue.main.async {
            self.pauseSession()
            self.reset()
            self.arSCNView?.removeFromSuperview()
            self.arSCNView = nil
         }
    }
    
    func pause() async {
        DispatchQueue.main.async {
            self.pauseSession()
            self.reset()
         }
    }
   
    func addTapGesture(){
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didRecieveTapGesture(_:)))
        arSCNView?.addGestureRecognizer(tapGestureRecognizer)
    }
     
    func pauseSession(){
        self.arSCNView?.session.pause()
    }

    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        //let childrens = self.arSCNView?.scene.rootNode.childNodes.count ?? 0
        //debugLog(object: "Rootnode childrens: \(childrens)")
        DispatchQueue.main.async {
            if let planeAnchor = anchor as? ARPlaneAnchor{
                let plane = ARPlane(anchor: planeAnchor)
                node.addChildNode(plane)
                self.planes[planeAnchor] = plane
            }
        }
        
        /*if let planeAnchor = anchor as? ARPlaneAnchor{
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
        }*/
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
        DispatchQueue.main.async {
            if let planeAnchor = anchor as? ARPlaneAnchor,
               let plane = self.planes[planeAnchor]{
                plane.updateWith(planeAnchor)
            }
        }
    }
    
    func renderer(_ renderer:SCNSceneRenderer,didRemove node: SCNNode,for anchor:ARAnchor){
        if let planeAnchor = anchor as? ARPlaneAnchor{
            self.planes.removeValue(forKey: planeAnchor)
        }
    }
    
    func renderer(_ renderer:SCNSceneRenderer,updateAtTime time:TimeInterval){
        if let currentPosition = castQueryFromCenterView(),
           let firstNode = firstNode{
            self.lineNode?.removeFromParentNode()
            let lineNode = self.drawLineBetween(pos1: currentPosition, pos2: firstNode.position)
            self.lineNode = lineNode
            self.arSCNView?.scene.rootNode.addChildNode(lineNode)
            calculateDistanceBetweenTwoPoints(pos1:currentPosition,pos2: firstNode.position)
            
        }
    }
    
    @objc
    func didRecieveTapGesture(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: arSCNView)
        if let arSCNView = arSCNView,
            let query = arSCNView.raycastQuery(from: location,
                                              allowing: .estimatedPlane,
                                              alignment: .any),
            let hitTestResult = arSCNView.session.raycast(query).first{
            addCircle(raycastResult: hitTestResult)
            switch(nodeList.count){
            case 2:
                let n1 = nodeList[0].position,n2 = nodeList[1].position
                calculateAngleWithTwo(n1: n1, n2: n2)
            case 3:
                let n1 = nodeList[0].position, n2 = nodeList[1].position,n3 = nodeList[2].position
                calculateAngleWithTwo(n1: n1, n2: n3)
                calculateAngleWithThree(n1: n1, n2: n2, n3: n3)
            case 4:
                clearNodeList()
            default:
                 break
                
            }
            calculateDistance()
            //let anchor = ARAnchor(transform: hitTestResult.worldTransform)
            //arSCNView?.session.add(anchor: anchor)
        }
    }
    
    func castQueryFromCenterView() -> SCNVector3?{
        if let arSCNView = arSCNView,
           let query = arSCNView.raycastQuery(from: .zero,
                                             allowing: .estimatedPlane,
                                             alignment: .any),
           let hitTestResult = arSCNView.session.raycast(query).first{
            return self.transformMatrix(m:hitTestResult.worldTransform)
             
        }
        return nil
     }
 
    func sessionWasInterrupted(_ session: ARSession) {}
    func sessionInterruptionEnded(_ session: ARSession) {}
    //func sessionShouldAttemptRelocalization(_ session: ARSession) -> Bool {}
    func session(_ session: ARSession, didFailWithError error: Error){}
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        switch camera.trackingState {
        case ARCamera.TrackingState.notAvailable:
            info.status = "Not available"
        case ARCamera.TrackingState.limited(_):
            info.status = "Analyzing..."
        case ARCamera.TrackingState.normal:
            info.status = "Ready"
        }
     }
    func session(_ session: ARSession, didChange geoTrackingStatus: ARGeoTrackingStatus) {}
    func session(_ session: ARSession, didOutputCollaborationData data: ARSession.CollaborationData) {}
    func session(_ session: ARSession, didOutputAudioSampleBuffer audioSampleBuffer: CMSampleBuffer) {}
}

//MARK: -- DISTANCE HELPERS
extension ARCoordinator{
    func calculateDistance(){
        if(nodeList.count <= 1){ info.distance = "";return }
        var distance:SCNFloat = 0.0
        for i in (0..<nodeList.count-1){
            let n1 = nodeList[i].position,n2 = nodeList[i+1].position
            distance += n1.distance(to: n2,convert: .CENTIMETER)
        }
        info.distance = "Distance " + String(format: "%.2f cm", distance)
    }
    
    func calculateDistanceBetweenTwoPoints(pos1:SCNVector3,pos2:SCNVector3){
        let distance:SCNFloat = pos1.distance(to: pos2,convert: .CENTIMETER)
        info.distance = "Distance " + String(format: "%.2f cm", distance)
    }
    
    func calculateAngleWithTwo(n1:SCNVector3,n2:SCNVector3){
        let angle2 = SCNVector3.angleBetweenTwoPoints(n1: n1, n2: n2)
        info.angleTwo = "Angle: " + String(format: "%.2f", angle2)
    }
    
    func calculateAngleWithThree(n1:SCNVector3,n2:SCNVector3,n3:SCNVector3){
        let angle3 = SCNVector3.angleBetweenThreePoints(n1: n1, n2: n2, n3: n3)
        info.angleThree = "Angle Three: " + String(format: "%.2f", angle3)
    }
}

//MARK: -- POSITION HELPERS
extension ARCoordinator{
    func transformMatrix(m: matrix_float4x4) -> SCNVector3{
        return SCNVector3Make(m.columns.3.x, m.columns.3.y, m.columns.3.z)
    }
}

//MARK: -- ADD NODE HELPERS
extension ARCoordinator{
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
    
    func generateSphereNode() -> SCNNode {
        let dot = SCNBox(width: 0.01, height: 0.01, length: 0.01, chamferRadius: 0.01)
        dot.firstMaterial?.diffuse.contents = UIColor.blue.withAlphaComponent(1.0)
        let node = SCNNode(geometry: dot)
        
        return node
    }
    
    func addSphereNodeAt(_ position:SCNVector3){
        let sphere = SCNSphere(radius: 0.003)
        if let arSCNView = arSCNView,
           let firstMaterial = sphere.firstMaterial{
            firstMaterial.diffuse.contents = UIColor.blue.withAlphaComponent(1.0)
            firstMaterial.lightingModel = .constant
            firstMaterial.isDoubleSided = true
            
            let node = SCNNode(geometry: sphere)
            node.position = position
            arSCNView.scene.rootNode.addChildNode(node)
        }
    }
             
}
    
//MARK: -- ADD LINE HELPERS
extension ARCoordinator{
    func drawLineBetween(pos1: SCNVector3,pos2:SCNVector3) -> SCNNode{
        let lineGeo = lineGeometry(v1:pos1,v2:pos2)
        return SCNNode(geometry: lineGeo)
    }
    
    func lineGeometry(v1:SCNVector3,v2:SCNVector3) -> SCNGeometry{
        let indices: [Int32] = [0,1]
        let source = SCNGeometrySource(vertices: [v1,v2])
        let element = SCNGeometryElement(indices: indices, primitiveType: .line)
        return SCNGeometry(sources: [source], elements: [element])
    }
}
   
    

//MARK: -- PROPERTY HELPERS
extension ARCoordinator{
    func reset(){
        firstNode = nil
        lineNode = nil
        clearNodeList()
        clearStoredPlanes()
        clearText()
        clearScene()
    }
    func clearText(){
        info.clearAngleText()
        info.clearDistanceText()
        info.clearInfoStatusText()
    }
    func clearAngleText(){
        info.clearAngleText()
    }
    func clearDistanceText(){ info.clearDistanceText() }
    func clearInfoStatusText(){ info.clearInfoStatusText() }
    
    func clearStoredPlanes(){
        for key in planes.keys{
            planes.removeValue(forKey: key  )
        }
    }
    func clearNodeList(){
        for node in nodeList {
            node.removeFromParentNode()
        }
        nodeList.removeAll()
        info.clearAngleText()
    }
    
    func clearScene(){
        if let arSCNView = arSCNView{
            for node in arSCNView.scene.rootNode.childNodes{
                node.removeFromParentNode()
            }
        }
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
