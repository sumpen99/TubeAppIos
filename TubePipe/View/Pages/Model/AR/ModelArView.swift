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
    @State var showList:Bool = false
  
    init() {
        self._arSceneViewModel = StateObject(wrappedValue: ARSceneViewModel())
        self._cameraManager = StateObject(wrappedValue: CameraManger())
        self._arCoordinator = StateObject(wrappedValue: ARCoordinator())
     }
    
    var arModel: some View {
         ARSceneView(arCoordinator: arCoordinator)
         .ignoresSafeArea(.all)
    }
    
    var storedMeasurements:[ARMeasurement] = [
        ARMeasurement(name: "1", type: .POINT, length: 10.0, angle: 45.0),
        ARMeasurement(name: "2", type: .POINT, length: 10.0, angle: 45.0),
        ARMeasurement(name: "3", type: .POINT, length: 10.0, angle: 45.0),
        ARMeasurement(name: "4", type: .POINT, length: 10.0, angle: 45.0),
        ARMeasurement(name: "5", type: .POINT, length: 10.0, angle: 45.0),
        ARMeasurement(name: "6", type: .POINT, length: 10.0, angle: 45.0),
        ARMeasurement(name: "7", type: .POINT, length: 10.0, angle: 45.0),
        ARMeasurement(name: "8", type: .POINT, length: 10.0, angle: 45.0),
        ARMeasurement(name: "9", type: .POINT, length: 10.0, angle: 45.0),
        ARMeasurement(name: "10", type: .POINT, length: 10.0, angle: 45.0),
    ]
    
    @ViewBuilder
    var measurePointList:some View{
        if showList{
            GeometryReader{ reader in
                ZStack{
                    Color.white.opacity(0.5)
                    ScrollView{
                        VStack{
                            ForEach(arCoordinator.storedMeasurements,id:\.self){ measurement in
                                if let length = measurement.length,
                                   let name = measurement.name{
                                    VStack(spacing:V_SPACING_REG){
                                        Text(name).avatar(color:Color.darkGray).hLeading()
                                        Text(String(format: "%.2f cm", length))
                                        .font(.body)
                                        .bold()
                                        .foregroundStyle(Color.darkGray)
                                        .hLeading()
                                    }
                                    .padding()
                               }
                            }
                        }
                    }
                }
                .frame(width:reader.size.width/3)
                .vTop()
                .hTrailing()
                .padding([.trailing,.top])
            }
            .transition(.move(edge: .trailing))
        }
        
        
        
    }
     
    var takeMeasurementMode:some View{
        GeometryReader{ reader in
            ZStack{
                measurePointList
                ScannerFrame(size: reader.size)
                bottomButtons
            }
            .task {
                await arCoordinator.pause()
                await arCoordinator.switchTo(scene: SCNScene(),allowCameraControl: false)
            }
        }
        
    }
    
    var showTubeModelMode:some View{
        HStack{
            zoomXButton
            zoomYButton.hCenter()
            zoomZButton
         }
        .task {
            tubeViewModel.initFromCache()
            await arCoordinator.pause()
            await renderNewScene()
            await arCoordinator.switchTo(scene: arSceneViewModel.scnScene,allowCameraControl: true)
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
            arSceneViewModel.publishScene()
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
    
    var zoomXButton:some View{
        RoundedButton(action: {
            arCoordinator.zoom(direction:0)
        }, imageName: "x.circle",radius: 62.0,color: Color.systemBlue,font: .largeTitle)
    }
    
    var zoomYButton:some View{
        RoundedButton(action: {
            arCoordinator.zoom(direction:1)
        }, imageName: "y.circle",radius: 62.0,color: Color.systemBlue,font: .largeTitle)
    }
    
    var zoomZButton:some View{
        RoundedButton(action: {
            arCoordinator.zoom(direction:2)
        }, imageName: "z.circle",radius: 62.0,color: Color.systemBlue,font: .largeTitle)
    }
    
    var bottomButtons:some View{
        HStack{
            showAngleButton
            addMeasurePointButton.hCenter()
            showDistanceButton
         }
        .vBottom()
        .hCenter()
        .padding()
    }
    
    var addMeasurePointButton:some View{
        RoundedButton(action:addMeasurePointWith, 
                      imageName: "plus",
                      radius: 62.0,
                      color: Color.systemGreen,
                      font:.largeTitle)
        .scaleEffect(CGSize(width: 1.3, height: 1.3))
       
    }
    
    var showDistanceButton:some View{
        RoundedButton(action:toggleList, 
                      imageName: "list.clipboard",
                      radius: 52.0,
                      color: Color.black.opacity(0.6),
                      font: .title)
        .scaleEffect(CGSize(width: 1.3, height: 1.3))
        .padding(.trailing)
    
    }
    
    var showAngleButton:some View{
        RoundedButton(action:toggleList, 
                      imageName: "list.bullet",
                      radius: 52.0,
                      color: Color.black.opacity(0.6),
                      font: .title)
        .scaleEffect(CGSize(width: 1.3, height: 1.3))
        .padding(.leading)
   
    }
}

//MARK: -- HELPER
extension ModelArView{
    
    func addMeasurePointWith(){
        if let position = arCoordinator.castQueryFromCenterView(){
            arCoordinator.addSphere(position)
            arCoordinator.addLine()
            arCoordinator.addAngle()
            
        }
    }
    
    func toggleList(){
        withAnimation{
            showList.toggle()
        }
    }
    
    func closeView(){
        dismiss()
    }
}

