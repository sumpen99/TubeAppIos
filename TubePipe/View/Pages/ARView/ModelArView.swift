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

enum ActiveARMode: Identifiable {
    case TAKE_MEASUREMENT
    case SHOW_TUBE_MODEL
     
    var id: Int {
        hashValue
    }
}

struct ModelArView: View{
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var navigationViewModel: NavigationViewModel
    @EnvironmentObject var tubeViewModel: TubeViewModel
    @StateObject private var arSceneViewModel: ARSceneViewModel
    @StateObject private var cameraManager: CameraManger
    @StateObject private var arCoordinator: ARCoordinator
    @State var activeARSheet: ActiveARSheet?
    @State var activeARMode: ActiveARMode?
    @State var renderNewState:Bool = false
  
    init() {
        self._arSceneViewModel = StateObject(wrappedValue: ARSceneViewModel())
        self._cameraManager = StateObject(wrappedValue: CameraManger())
        self._arCoordinator = StateObject(wrappedValue: ARCoordinator())
     }
    
    var arModel: some View {
         ARSceneView(arCoordinator: arCoordinator)
         .ignoresSafeArea(.all)
    }
    
    var takeMeasurementMode:some View{
        ZStack{
            Image("focus")
        }
        .task {
            await arCoordinator.pause()
            await arCoordinator.switchTo(scene: SCNScene(),allowCameraControl: false)
        }
        .hCenter()
        .vCenter()
    }
    
    var showTubeModelMode:some View{
        HStack{
            //clearNodeButton
            //debugText
            zoomXButton
            zoomYButton.hCenter()
            zoomZButton
            //clearTextButton
        }
        .task {
            tubeViewModel.initFromCache()
            await arCoordinator.pause()
            await renderNewScene()
            await arCoordinator.switchTo(scene: arSceneViewModel.scnScene,allowCameraControl: true)
            //await arCoordinator.zoom()
        }
        .vBottom()
        .padding()
    }
    
    @ViewBuilder
    var currentMode:some View{
        if(activeARMode == .SHOW_TUBE_MODEL){
            showTubeModelMode
        }
        else if(activeARMode == .TAKE_MEASUREMENT){
            takeMeasurementMode
        }
    }
    
    var modelPage:some View{
        ZStack{
            if cameraManager.permission.isAuthorized{
                ZStack{
                    arModel
                    currentMode
                }
            }
            else if cameraManager.permission.status != .notDetermined && canOpenSettingsUrl(){
                missingPermissionView
            }
         }
        .task{
            await cameraManager.setUpCaptureSession()
        }
    }
        
    var body:some View{
        AppBackgroundStack(content: {
            modelPage
        })
        .onDisappear{
            arCoordinator.kill()
        }
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
            ToolbarItemGroup(placement: .principal){
                switchModeButtons
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu{
                    takeMeasurementButton.padding()
                    loadTubeButton.padding()
                    saveValuesButton.padding()
                 }
            label:{
                Image(systemName: "ellipsis.circle").toolbarFontAndPadding()
            }
            }
        }
    }
    
    
}

//MARK: -- RENDER SCENE OPTIONS
extension ModelArView{
    func renderNewScene() async {
        DispatchQueue.main.async {
            arSceneViewModel.reset()
            arSceneViewModel.setRenderState(tubeViewModel.collectModelRenderState())
            arSceneViewModel.buildModelFromTubePoints(tubeViewModel.pointsWithAddedCircle(
                renderSizePart: arSceneViewModel.renderSizePart),
                                                        dimension: tubeViewModel.settingsVar.tube.dimension)
            //arSceneViewModel.buildSteelFromTubePoints(tubeViewModel.steelPotentiallyScaled(renderSizePart: arSceneViewModel.renderSizePart),dimension: tubeViewModel.settingsVar.tube.steel)
             
            //arSceneViewModel.addWorldAxis()
            arSceneViewModel.publishScene()
            //arSceneViewModel.rotateParentNode()
            //arSceneViewModel.zoomScene()
        }
        
    }
}

//MARK: -- NAVIGATION BUTTONS
extension ModelArView{
    var switchModeButtons:some View{
        HStack{
            IsOnButton(isOn: $activeARMode,
                       identity: ActiveARMode.TAKE_MEASUREMENT,
                       imgLabel: "viewfinder.rectangular", action: {})
            IsOnButton(isOn: $activeARMode,
                       identity: ActiveARMode.SHOW_TUBE_MODEL,
                       imgLabel: "light.cylindrical.ceiling", action: {})
        }
        .toolbarFontAndPadding()
    }
    
    var takeMeasurementButton:some View{
        Button(action: {
            
        } ){
            Label("Measurement", systemImage: "ruler")
        }
    }
    
    var loadTubeButton:some View{
        Button(action: { debugLog(object: "Load Tube") } ){
            Label("Measurement", systemImage: "ruler")
        }
    }
    
    var saveValuesButton:some View{
        Button(action: { debugLog(object: "Save values") } ){
            Label("Measurement", systemImage: "ruler")
        }
    }
}

//MARK: -- CHILDREN VIEWS
extension ModelArView{
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
    
    var clearTextButton:some View{
        Button("Clear text", action: self.arCoordinator.clearText )
        .hTrailing()
        .font(.title3)
        .foregroundStyle(Color.white)
        .buttonStyle(.borderedProminent)
        .tint(Color.systemRed)
    }
    
    var clearNodeButton:some View{
        Button("Clear node", action: self.arCoordinator.clearNodeList )
        .hLeading()
        .font(.title3)
        .foregroundStyle(Color.white)
        .buttonStyle(.borderedProminent)
        .tint(Color.systemRed)
    }
    
    var debugText:some View{
        VStack(spacing: V_SPACING_REG){
            Text(arCoordinator.info.status ).foregroundStyle(Color.white)
            Text(arCoordinator.info.distance ).foregroundStyle(Color.white)
            Text(arCoordinator.info.angleTwo ).foregroundStyle(Color.white)
            Text(arCoordinator.info.angleThree ).foregroundStyle(Color.white)
        }
    }
    
    var zoomXButton:some View{
        RoundedButton(action: {
            arCoordinator.zoom(direction:0)
        }, imageName: "x.circle",radius: 62.0)
    }
    
    var zoomYButton:some View{
        RoundedButton(action: {
            arCoordinator.zoom(direction:1)
        }, imageName: "y.circle",radius: 62.0)
    }
    
    var zoomZButton:some View{
        RoundedButton(action: {
            arCoordinator.zoom(direction:2)
        }, imageName: "z.circle",radius: 62.0)
    }
}

//MARK: -- HELPER
extension ModelArView{
    
    func closeView(){
        dismiss()
    }
}