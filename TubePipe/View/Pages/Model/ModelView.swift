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
        .onAppear {
            renderNewScene()
        }
    }
    
    func renderNewScene(){
         DispatchQueue.global().async{
            tubeSceneViewModel.reset()
            tubeSceneViewModel.setRenderState(tubeViewModel.collectModelRenderState())
            tubeSceneViewModel.buildModelFromTubePoints(tubeViewModel.pointsWithAddedCircle(
                renderSizePart: tubeSceneViewModel.renderSizePart),
                                                        dimension: tubeViewModel.settingsVar.dimension)
            tubeSceneViewModel.buildSteelFromTubePoints(tubeViewModel.steelPotentiallyScaled(renderSizePart: tubeSceneViewModel.renderSizePart),dimension: tubeViewModel.settingsVar.steel)
             
            tubeSceneViewModel.addWorldAxis(dimension: tubeViewModel.settingsVar.dimension)
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
        let newVal = tubeViewModel.getUserdefaultDrawOptionValue(.SHOW_WORLD_AXIS)
        tubeViewModel.setUserdefaultDrawOption(with: !newVal, op: .SHOW_WORLD_AXIS)
        tubeViewModel.saveUserDefaultDrawingValues()
        renderNewScene()
    }
    
    var body:some View{
        NavigationView{
            AppBackgroundStack(content: {
                modelPage
            })
            .environmentObject(tubeSceneViewModel)
            .modifier(NavigationViewModifier(title: ""))
            .sheet(item: $activeModelSheet){ item in
                switch item{
                case ActiveModelSheet.OPEN_MODEL_SETTINGS:
                    ModelSettingsView(renderNewState: $renderNewState)
                    .presentationDragIndicator(.visible)
                    .presentationDetents([.medium])
                }
                
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { activeModelSheet = .OPEN_MODEL_SETTINGS }) {
                        Image(systemName: "gear")
                    }
                }
                ToolbarItem(placement: .principal) {
                    Button(action: toggleWorldAxis){
                        RotateImageView(isActive:
                                            self.$tubeViewModel.userDefaultSettingsVar.drawOptions[DrawOption.indexOf(op: .SHOW_WORLD_AXIS)],
                                        name: "move.3d")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination:LazyDestination(destination: {
                        ModelHelpView()
                    })){
                        Image(systemName: "info.circle")
                    }
                }
            }
         }
   }
    
}
