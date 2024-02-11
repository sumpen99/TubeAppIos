//
//  ARCoordinator.swift
//  TubePipe
//
//  Created by fredrik sundström on 2024-01-21.
//
import SwiftUI
import ARKit

struct ArInfo{
    var status:String = ""
    mutating func clearInfoStatusText(){ status = "" }
}

class ARCoordinator: NSObject, ARSCNViewDelegate,ObservableObject {
    var currentPosition:SCNVector3?
    var currentLine:SCNNode?
    var currentText:SCNNode?
    var arSCNView: ARSCNView?
    var nodeList:[SCNVector3] = []
    @Published var info:ArInfo = ArInfo()
    
     
    func setARView(_ arSCNView: ARSCNView) {
        self.arSCNView = arSCNView
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]
        configuration.isLightEstimationEnabled = true
    
        arSCNView.autoenablesDefaultLighting = true
        arSCNView.automaticallyUpdatesLighting = true
        //arSCNView.showsStatistics = true
        
        arSCNView.debugOptions = [ARSCNDebugOptions .showFeaturePoints]
        arSCNView.session.run(configuration,options: [.resetTracking, .removeExistingAnchors])
        arSCNView.delegate = self
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
     
    func pauseSession(){
        self.arSCNView?.session.pause()
    }
    
    func renderer(_ renderer:SCNSceneRenderer,updateAtTime time:TimeInterval){
        DispatchQueue.main.async {
            if let last = self.nodeList.last{
               if let currentPosition = self.castQueryFromCenterView(){
                   let lineNode = ARLineNode(pos1: last, pos2: currentPosition)
                   let textNode = self.orientatedText(pos1: last, pos2: currentPosition, orientation: .POINT)
                    self.currentText?.removeFromParentNode()
                    self.currentLine?.removeFromParentNode()
                    self.currentText = textNode
                    self.currentLine = lineNode
                    self.arSCNView?.scene.rootNode.addChildNode(lineNode)
                    self.arSCNView?.scene.rootNode.addChildNode(textNode)
                 }
            }
        }
    }
    
    func castQueryFromCenterView() -> SCNVector3?{
        if let arSCNView = arSCNView,
           let query = arSCNView.raycastQuery(from: arSCNView.center,
                                              allowing: .estimatedPlane,
                                              alignment: .any),
           let hitTestResult = arSCNView.session.raycast(query).first{
            return SCNVector3(translation: hitTestResult.worldTransform)
             
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
        if(nodeList.count <= 1){ return }
        var distance:SCNFloat = 0.0
        for i in (0..<nodeList.count-1){
            let n1 = nodeList[i],n2 = nodeList[i+1]
            distance += n1.distance(to: n2,convert: .CENTIMETER)
        }
        //info.distance = "Distance " + String(format: "%.2f cm", distance)
    }
    
    func calculateDistanceBetweenTwoPoints(pos1:SCNVector3,pos2:SCNVector3) -> String{
        let distance:SCNFloat = pos1.distance(to: pos2,convert: .CENTIMETER)
        return String(format: "%.2f cm", distance)
    }
    
    func calculateAngleWithTwo(n1:SCNVector3,n2:SCNVector3){
        let _ = SCNVector3.angleBetweenTwoPoints(n1: n1, n2: n2)
        //info.angleTwo = "Angle: " + String(format: "%.2f", angle2)
    }
    
    func calculateAngleWithThree(n1:SCNVector3,n2:SCNVector3,n3:SCNVector3){
        let _ = SCNVector3.angleBetweenThreePoints(n1: n1, n2: n2, n3: n3)
        //info.angleThree = "Angle Three: " + String(format: "%.2f", angle3)
    }
}

//MARK: -- ADD NODE HELPERS
extension ARCoordinator{
    
    func addSphere(_ position:SCNVector3){
        let sphereNode = ARSphereNode(position: position)
        nodeList.append(sphereNode.position)
        arSCNView?.scene.rootNode.addChildNode(sphereNode)
    }
    
    func addLine(){
        if nodeList.count > 1{
            let count = nodeList.count
            let first = nodeList[count-2]
            let last = nodeList[count-1]
            let lineNode = ARLineNode(pos1: first, pos2: last)
            let textNode = orientatedText(pos1: first, pos2: last,orientation: .CENTER)
            lineNode.removeFromParentNode()
            textNode.removeFromParentNode()
            arSCNView?.scene.rootNode.addChildNode(textNode)
            arSCNView?.scene.rootNode.addChildNode(lineNode)
            
        }
    }
             
}

//MARK: -- ADD TEXT HELPERS
extension ARCoordinator{
   
    func orientatedText(pos1: SCNVector3,pos2:SCNVector3,orientation:TextOrientation) -> SCNNode{
        var euler:SCNVector3?
        if let arScnView = arSCNView,
           let frame = arScnView.session.currentFrame {
            let eulerAngles = frame.camera.eulerAngles
            euler = SCNVector3(eulerAngles.x, eulerAngles.y, eulerAngles.z + .pi / 2)
        }
        let textNode = ARTextNode(pos1: pos1,
                                  pos2: pos2,
                                  orientation: orientation,
                                  euler: euler)
        textNode.initialize()
        return textNode
    }
     
}
   
//MARK: -- PROPERTY HELPERS
extension ARCoordinator{
    func reset(){
        currentLine = nil
        currentText = nil
        clearNodeList()
        clearText()
        clearScene()
    }
    func clearText(){
        info.clearInfoStatusText()
    }
    func clearNodeList(){
        nodeList.removeAll()
    }
    
    func clearScene(){
        if let arSCNView = arSCNView{
            for node in arSCNView.scene.rootNode.childNodes{
                node.removeFromParentNode()
            }
        }
    }
}

//MARK: -- OLD FUNCTIONS NO LONGER NEEDED
extension ARCoordinator{
    
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
    
    /*func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        DispatchQueue.main.async {
            if let planeAnchor = anchor as? ARPlaneAnchor{
                debugLog(object: "<-- FOUND PLANE -->")
                let plane = ARPlane(anchor:planeAnchor,in: arSCNView)
                node.addChildNode(plane)
            }
        }
    }*/

    //func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {}
    
    //func renderer(_ renderer:SCNSceneRenderer,didRemove node: SCNNode,for anchor:ARAnchor){}
    
    func addTapGesture(){
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didRecieveTapGesture(_:)))
        arSCNView?.addGestureRecognizer(tapGestureRecognizer)
    }
    
    
    @objc
    func didRecieveTapGesture(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: arSCNView)
        if let arSCNView = arSCNView,
           let query = arSCNView.raycastQuery(from: location,
                                              allowing: .estimatedPlane,
                                              alignment: .any),
            let _ = arSCNView.session.raycast(query).first{
            
        }
    }
    
    
}

