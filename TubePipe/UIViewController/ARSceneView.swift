//
//  ARView.swift
//  TubePipe
//
//  Created by fredrik sundström on 2024-01-11.
//
import ARKit
import SwiftUI
struct ARSceneView: UIViewRepresentable {
    typealias UIViewType = ARSCNView
    typealias Context = UIViewRepresentableContext<ARSceneView>
    typealias Coordinator = ARCoordinator
    let arCoordinator:ARCoordinator
    
    func makeUIView(context: Context) -> UIViewType {
        let arSCNView = ARSCNView(frame: .zero)
        arCoordinator.setARView(arSCNView)
        return arSCNView
   }
    
    func updateUIView(_ arSCNView: ARSCNView, context: Context) {
        //debugLog(object: "updateARView: \(arSCNView.debugDescription)")
    }
    
    static func dismantleUIView(_ arSCNView: ARSCNView, coordinator: Coordinator) {
        coordinator.pauseSession()
        //debugLog(object: "dismantleARView: \(arSCNView.debugDescription)")
    }
    
    func makeCoordinator() -> Coordinator {
        return arCoordinator
    }
    
}
