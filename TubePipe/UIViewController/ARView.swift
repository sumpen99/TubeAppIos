//
//  ARView.swift
//  TubePipe
//
//  Created by fredrik sundström on 2024-01-11.
//

//https://blog.devgenius.io/implementing-ar-in-swiftui-without-storyboards-ec529ace7ab2
//https://stackoverflow.com/questions/64139575/is-it-possible-to-use-swiftui-for-ui-in-an-ar-app-using-scenekit
//https://stackoverflow.com/questions/64896064/can-i-use-zoom-with-arview
import Foundation
import ARKit
import SwiftUI


// MARK: - ARViewIndicator
/*struct ARViewIndicator: UIViewControllerRepresentable {
   typealias UIViewControllerType = ARView
   
   func makeUIViewController(context: Context) -> ARView {
      return ARView()
   }
   func updateUIViewController(_ uiViewController:
   ARViewIndicator.UIViewControllerType, context:
   UIViewControllerRepresentableContext<ARViewIndicator>) { }
}*/

// MARK: - NavigationIndicator
struct NavigationIndicator: UIViewControllerRepresentable {
   typealias UIViewControllerType = ARView
   var scene: SCNScene
   func makeUIViewController(context: Context) -> ARView {
       let arView = ARView()
       arView.scnScene = scene
       return arView
   }
   func updateUIViewController(_ uiViewController:
   NavigationIndicator.UIViewControllerType, context:
   UIViewControllerRepresentableContext<NavigationIndicator>) { }
}

class ARView:UIViewController,ARSCNViewDelegate{
    var scnScene:SCNScene = SCNScene()
    var arView:ARSCNView{
        return self.view as! ARSCNView
    }
    
    override func loadView(){
        self.view = ARSCNView(frame: .zero)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        debugLog(object: "viewDidLoad")
        arView.delegate = self
        arView.scene = scnScene
    }
    
    // MARK: - Functions for standard AR view handling
       override func viewDidAppear(_ animated: Bool) {
          super.viewDidAppear(animated)
       }
       override func viewDidLayoutSubviews() {
          super.viewDidLayoutSubviews()
       }
       override func viewWillAppear(_ animated: Bool) {
          super.viewWillAppear(animated)
          let configuration = ARWorldTrackingConfiguration()
          arView.session.run(configuration)
          arView.delegate = self
       }
       override func viewWillDisappear(_ animated: Bool) {
          super.viewWillDisappear(animated)
          arView.session.pause()
       }
    
       // MARK: - ARSCNViewDelegate
       func sessionWasInterrupted(_ session: ARSession) {}
       
       func sessionInterruptionEnded(_ session: ARSession) {}
       func session(_ session: ARSession, didFailWithError error: Error)
       {}
       func session(_ session: ARSession, cameraDidChangeTrackingState
       camera: ARCamera) {}
}

struct ARViewRepresentable: UIViewRepresentable {
    let arDelegate:ARDelegate
    var scene: SCNScene
    var arView = ARSCNView(frame: .zero)
    
    func makeUIView(context: Context) -> some UIView {
        arView.backgroundColor = UIColor.clear
        arView.allowsCameraControl = true
        arView.autoenablesDefaultLighting = true
        arView.scene = scene
        arDelegate.setARView(arView)
        return arView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
    }
}

class ARDelegate: NSObject, ARSCNViewDelegate, ObservableObject {
    var arSCNView: ARSCNView?

    func setARView(_ arView: ARSCNView) {
        self.arSCNView = arView
                
        guard ARFaceTrackingConfiguration.isSupported else { return }
        guard self.arSCNView != nil else { return }
        //let configuration = ARFaceTrackingConfiguration()
        
        //let configuration = ARWorldTrackingConfiguration()
        //configuration.isLightEstimationEnabled = true
        //arView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        
        let configuration = ARWorldTrackingConfiguration()
        arView.session.run(configuration)
       
        
        arView.delegate = self
        //arView.scene = SCNScene()
    }

    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {

        // do some node transform stuff
        //...

        //trackDistance()
    }

    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        // do some node transform stuff
        //...
        //trackDistance()
    }
}
