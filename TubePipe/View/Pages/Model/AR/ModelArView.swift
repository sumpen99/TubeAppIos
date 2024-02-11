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
    
    var scannerBox: some View{
        GeometryReader { geometry in
            
        }
    }

    private func createCornersPath(size:CGSize) -> Path {
        let centerWidth = size.width/2.0
        let centerHeight = size.height/2.0
        var path = Path()
        let left = centerWidth-25.0
        let right = centerWidth+25.0
        let top = centerHeight-25.0
        let bottom = centerHeight+25.0
        let width = right - left
        let radius = width / 20.0 / 2.0
        let cornerLength = width / 10.0

        path.move(to: CGPoint(x: left, y: top + radius))
        path.addArc(
            center: CGPoint(x: left + radius, y: top + radius),
            radius: radius,
            startAngle: Angle(degrees: 180.0),
            endAngle: Angle(degrees: 270.0),
            clockwise: false
        )

        path.move(to: CGPoint(x: left + radius, y: top))
        path.addLine(to: CGPoint(x: left + radius + cornerLength, y: top))

        path.move(to: CGPoint(x: left, y: top + radius))
        path.addLine(to: CGPoint(x: left, y: top + radius + cornerLength))

        path.move(to: CGPoint(x: right - radius, y: top))
        path.addArc(
            center: CGPoint(x: right - radius, y: top + radius),
            radius: radius,
            startAngle: Angle(degrees: 270.0),
            endAngle: Angle(degrees: 360.0),
            clockwise: false
        )

        path.move(to: CGPoint(x: right - radius, y: top))
        path.addLine(to: CGPoint(x: right - radius - cornerLength, y: top))

        path.move(to: CGPoint(x: right, y: top + radius))
        path.addLine(to: CGPoint(x: right, y: top + radius + cornerLength))

        path.move(to: CGPoint(x: left + radius, y: bottom))
        path.addArc(
            center: CGPoint(x: left + radius, y: bottom - radius),
            radius: radius,
            startAngle: Angle(degrees: 90.0),
            endAngle: Angle(degrees: 180.0),
            clockwise: false
        )
        
        path.move(to: CGPoint(x: left + radius, y: bottom))
        path.addLine(to: CGPoint(x: left + radius + cornerLength, y: bottom))

        path.move(to: CGPoint(x: left, y: bottom - radius))
        path.addLine(to: CGPoint(x: left, y: bottom - radius - cornerLength))

        path.move(to: CGPoint(x: right, y: bottom - radius))
        path.addArc(
            center: CGPoint(x: right - radius, y: bottom - radius),
            radius: radius,
            startAngle: Angle(degrees: 0.0),
            endAngle: Angle(degrees: 90.0),
            clockwise: false
        )
        
        path.move(to: CGPoint(x: right - radius, y: bottom))
        path.addLine(to: CGPoint(x: right - radius - cornerLength, y: bottom))

        path.move(to: CGPoint(x: right, y: bottom - radius))
        path.addLine(to: CGPoint(x: right, y: bottom - radius - cornerLength))

        return path
    }

    
    var takeMeasurementMode:some View{
        GeometryReader{ reader in
            ZStack{
                //Image("focus").hCenter()
                Path { path in
                    path.addPath(
                        createCornersPath(size:reader.size)
                    )
                }
                .stroke(arCoordinator.currentPosition != nil ? Color.systemGreen : Color.systemBlue, lineWidth:2)
                .vCenter()
                .hCenter()
                addMeasurePointButton
                
            }
            .hCenter()
            .vCenter()
            .task {
                await arCoordinator.pause()
                await arCoordinator.switchTo(scene: SCNScene(),allowCameraControl: false)
            }
        }
        
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
        Text(arCoordinator.info.status ).foregroundStyle(Color.white)
    }
    
    var zoomXButton:some View{
        RoundedButton(action: {
            arCoordinator.zoom(direction:0)
        }, imageName: "x.circle",radius: 62.0,color: Color.systemBlue)
    }
    
    var zoomYButton:some View{
        RoundedButton(action: {
            arCoordinator.zoom(direction:1)
        }, imageName: "y.circle",radius: 62.0,color: Color.systemBlue)
    }
    
    var zoomZButton:some View{
        RoundedButton(action: {
            arCoordinator.zoom(direction:2)
        }, imageName: "z.circle",radius: 62.0,color: Color.systemBlue)
    }
    
    var addMeasurePointButton:some View{
        RoundedButton(action:addMeasurePointWith, imageName: "plus",radius: 62.0,color: Color.systemGreen)
        .scaleEffect(CGSize(width: 1.3, height: 1.3))
        .vBottom()
        .hCenter()
        .padding(.bottom)
    }
}

//MARK: -- HELPER
extension ModelArView{
    
    func addMeasurePointWith(){
        if let position = arCoordinator.castQueryFromCenterView(){
            arCoordinator.addSphere(position)
            arCoordinator.addLine()
            
        }
    }
    
    func closeView(){
        dismiss()
    }
}

