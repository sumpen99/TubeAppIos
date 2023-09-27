//
//  TubeSceneView.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-09-09.
//

import SwiftUI
import SceneKit

class Camera{
    var cameraEye = SCNNode()
    var cameraFocus = SCNNode()
        
    var centerX: Int = 100
    var strafeDelta: Float = 0.8
    var zoomLevel: Int = 35
    var zoomLevelMax: Int = 35              // Max number of zoom levels
    
    //********************************************************************
    init()
    {
        cameraEye.name = "Camera Eye"
        cameraFocus.name = "Camera Focus"
        
        cameraFocus.isHidden = true
        cameraFocus.position  =  SCNVector3(x: 0, y: 0, z: 100)
        
        cameraEye.camera = SCNCamera()
        cameraEye.constraints = []
        cameraEye.position = SCNVector3(x: 0, y: 0, z: 0)
        
        let vConstraint = SCNLookAtConstraint(target: cameraFocus)
        vConstraint.isGimbalLockEnabled = true
        cameraEye.constraints = [vConstraint]
    }
    //********************************************************************
    func reset()
    {
        centerX = 100
        cameraFocus.position  =  SCNVector3(x: 0, y: 0, z: 0)
        cameraEye.constraints = []
        cameraEye.position = SCNVector3(x: 0, y: 32, z: 0.1)
        cameraFocus.position = SCNVector3Make(0, 0, 0)
        
        let vConstraint = SCNLookAtConstraint(target: cameraFocus)
        vConstraint.isGimbalLockEnabled = true
        cameraEye.constraints = [vConstraint]
    }
    //********************************************************************
    func strafeRight()
    {
        if(centerX + 1 < 112)
        {
            centerX += 1
            cameraEye.position.x += strafeDelta
            cameraFocus.position.x += strafeDelta
        }
    }
    //********************************************************************
    func strafeLeft()
    {
        if(centerX - 1 > 90)
        {
            centerX -= 1
            cameraEye.position.x -= strafeDelta
            cameraFocus.position.x -= strafeDelta
        }
    }
    //********************************************************************
}

struct TubeSceneView: UIViewRepresentable {
    typealias UIViewType = SCNView
    typealias Context = UIViewRepresentableContext<TubeSceneView>
    var scene: SCNScene
    var view = SCNView()
   
    func updateUIView(_ uiView: UIViewType, context: Context) {}
    func makeUIView(context: Context) -> UIViewType {
        view.backgroundColor = UIColor.clear 
        view.allowsCameraControl = true
        view.autoenablesDefaultLighting = true
        view.scene = scene
        return view
    }
    
    func disablePanGesture(){
        for reco in view.gestureRecognizers ?? [] {
            if let panReco = reco as? UIPanGestureRecognizer {
                panReco.maximumNumberOfTouches = 1
            }
        }
    }
    
    func lockOnXAxis(){
        view.defaultCameraController.maximumVerticalAngle = 0.001
    }
    
    func lockOnYAxis(){
        view.defaultCameraController.maximumHorizontalAngle = 0.001
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(view)
    }

    class Coordinator: NSObject {
        private let view: SCNView
        init(_ view: SCNView) {
            self.view = view
            super.init()
        }
    }
}

