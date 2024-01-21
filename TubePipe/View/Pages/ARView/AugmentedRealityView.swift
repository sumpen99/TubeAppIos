//
//  AugmentedRealityView.swift
//  TubePipe
//
//  Created by fredrik sundström on 2024-01-12.
//

import SwiftUI
import SceneKit

enum ActiveARSheet: Identifiable {
    case OPEN_MODEL_SETTINGS
    
    var id: Int {
        hashValue
    }
}

struct AugmnentedRealityView: View{
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var tubeViewModel: TubeViewModel
    @StateObject private var arSceneViewModel: ARSceneViewModel
    @StateObject private var cameraManager: CameraManger
    @StateObject private var arCoordinator: ARCoordinator
    @State var activeARSheet: ActiveARSheet?
    @State var renderNewState:Bool = false
  
    init() {
        self._arSceneViewModel = StateObject(wrappedValue: ARSceneViewModel())
        self._cameraManager = StateObject(wrappedValue: CameraManger())
        self._arCoordinator = StateObject(wrappedValue: ARCoordinator())
     }
    
    var modelPage: some View {
        //TubeARView(scene:arSceneViewModel.scnScene)
        TubeARView(arCoordinator: arCoordinator)
        .ignoresSafeArea(.all)
        .onChange(of: renderNewState){ newValue in
            Task {
                renderNewScene()
            }
        }
        .task {
            tubeViewModel.initFromCache()
            renderNewScene()
        }
    }
    
    var missingPermissionView:some View{
        VStack(spacing:V_SPACING_REG){
            Text("Permission required").bold()
            Text("Augmented reality require camera access. As of current TubePipe is not allowed to access this resource. You can change status inside settings")
            Button("Settings", action: openPrivacySettings)
            .buttonStyle(.bordered)
            .foregroundStyle(Color.systemBlue)
            .hTrailing()
        }
        .roundedBorderWithShadow()
        .padding()
    }
    
    func renderNewScene(){
        arSceneViewModel.reset()
        arSceneViewModel.setRenderState(tubeViewModel.collectModelRenderState())
        arSceneViewModel.buildModelFromTubePoints(tubeViewModel.pointsWithAddedCircle(
            renderSizePart: arSceneViewModel.renderSizePart),
                                                    dimension: tubeViewModel.settingsVar.tube.dimension)
        arSceneViewModel.buildSteelFromTubePoints(tubeViewModel.steelPotentiallyScaled(renderSizePart: arSceneViewModel.renderSizePart),dimension: tubeViewModel.settingsVar.tube.steel)
         
        arSceneViewModel.addWorldAxis()
        arSceneViewModel.rotateParentNode()
        arSceneViewModel.zoomScene()
        arSceneViewModel.publishScene()
    }
  
    func closeView(){
        dismiss()
    }
    
    @ViewBuilder
    var body:some View{
        ZStack{
            if cameraManager.permission.isAuthorized{
                modelPage
            }
            else if cameraManager.permission.status != .notDetermined && canOpenSettingsUrl(){
                missingPermissionView
            }
         }
        .task{
            await cameraManager.setUpCaptureSession()
        }
    }
        
    var body1:some View{
        AppBackgroundStack(content: {
            modelPage
        })
        .navigationBarBackButtonHidden()
        .onChange(of: activeARSheet){ item in
            if let item{
                activeARSheet = nil
                switch item{
                case ActiveARSheet.OPEN_MODEL_SETTINGS:
                    SheetPresentView(style: .detents([.medium()])){
                        Model3DSettingsView(renderNewState: $renderNewState)
                        .environmentObject(tubeViewModel)
                    }
                    .makeUIView()
               }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { activeARSheet = .OPEN_MODEL_SETTINGS }) {
                    Image(systemName: "gear")
                }
                .toolbarFontAndPadding()
            }
            ToolbarItem(placement: .principal) {
                Button(action: closeView){
                    ZStack{
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .font(.title)
                            .foregroundStyle(Color.systemBlue)
                        Image(systemName: "view.2d")
                            .imageScale(.small)
                            .foregroundStyle(Color.systemBlue)
                    }
                }
                .toolbarFontAndPadding()
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination:LazyDestination(destination: {
                    Model3DHelpView()
                })){
                    Image(systemName: "info.circle")
                }
                .toolbarFontAndPadding()
            }
        }
            
   }
    
    
    
}

