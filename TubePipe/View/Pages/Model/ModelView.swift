//
//  ModelView.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-06-10.
//

import SwiftUI
import SceneKit

enum ActiveModelSheet: Identifiable {
    case OPEN_MODEL_SETTINGS
    
    var id: Int {
        hashValue
    }
}

struct ModelView: View{
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var tubeViewModel: TubeViewModel
    @StateObject private var tubeSceneViewModel: TubeSceneViewModel
    @State var activeModelSheet: ActiveModelSheet?
    @State var renderNewState:Bool = false
  
    init() {
        self._tubeSceneViewModel = StateObject(wrappedValue: TubeSceneViewModel())
    }
    
    var modelPage: some View {
        TubeSceneView(scene:tubeSceneViewModel.scnScene)
        .ignoresSafeArea(.all)
        .onChange(of: renderNewState){ newValue in
            renderNewScene()
        }
        .task {
            tubeViewModel.initFromCache()
            renderNewScene()
        }
    }
    
    func renderNewScene(){
         DispatchQueue.global().async{
            tubeSceneViewModel.reset()
            tubeSceneViewModel.setRenderState(tubeViewModel.collectModelRenderState())
            tubeSceneViewModel.buildModelFromTubePoints(tubeViewModel.pointsWithAddedCircle(
                renderSizePart: tubeSceneViewModel.renderSizePart),
                                                        dimension: tubeViewModel.settingsVar.tube.dimension)
            tubeSceneViewModel.buildSteelFromTubePoints(tubeViewModel.steelPotentiallyScaled(renderSizePart: tubeSceneViewModel.renderSizePart),dimension: tubeViewModel.settingsVar.tube.steel)
             
            tubeSceneViewModel.addWorldAxis()
            tubeSceneViewModel.rotateParentNode()
            tubeSceneViewModel.zoomScene()
            DispatchQueue.main.async {
                withAnimation{
                    tubeSceneViewModel.publishScene()
                }
            }
        }
    }
    
    func toggleWorldAxis(){
        dismiss()
        /*let newVal = tubeViewModel.getUserdefaultDrawOptionValue(.SHOW_WORLD_AXIS)
        tubeViewModel.setUserdefaultDrawOption(with: !newVal, op: .SHOW_WORLD_AXIS)
        tubeViewModel.saveUserDefaultDrawingValues()
        renderNewScene()*/
    }
    
    var body:some View{
        AppBackgroundStack(content: {
            modelPage
        })
        .navigationBarBackButtonHidden()
        .environmentObject(tubeSceneViewModel)
        .onChange(of: activeModelSheet){ item in
            if let item{
                activeModelSheet = nil
                switch item{
                case ActiveModelSheet.OPEN_MODEL_SETTINGS:
                    SheetPresentView(style: .detents([.medium()])){
                        ModelSettingsView(renderNewState: $renderNewState)
                        .environmentObject(tubeViewModel)
                        .presentationDragIndicator(.visible)
                    }
                    .makeUIView()
               }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { activeModelSheet = .OPEN_MODEL_SETTINGS }) {
                    Image(systemName: "gear")
                }
                .toolbarFontAndPadding()
            }
            ToolbarItem(placement: .principal) {
                Button(action: toggleWorldAxis){
                    Image(systemName: "arrow.left.arrow.right.circle")
                    //RotateImageViewDefault(name: "move.3d")
                }
                .toolbarFontAndPadding()
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination:LazyDestination(destination: {
                    ModelHelpView()
                })){
                    Image(systemName: "info.circle")
                }
                .toolbarFontAndPadding()
            }
        }
            
   }
    
}
