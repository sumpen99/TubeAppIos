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

struct Model3DView: View{
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
            Task {
                renderNewScene()
            }
        }
        .task {
            tubeViewModel.initFromCache()
            renderNewScene()
        }
    }
    
    func renderNewScene(){
        tubeSceneViewModel.reset()
        tubeSceneViewModel.setRenderState(tubeViewModel.collectModelRenderState())
        tubeSceneViewModel.buildModelFromTubePoints(tubeViewModel.pointsWithAddedCircle(
            renderSizePart: tubeSceneViewModel.renderSizePart),
                                                    dimension: tubeViewModel.settingsVar.tube.dimension)
        tubeSceneViewModel.buildSteelFromTubePoints(tubeViewModel.steelPotentiallyScaled(renderSizePart: tubeSceneViewModel.renderSizePart),dimension: tubeViewModel.settingsVar.tube.steel)
         
        tubeSceneViewModel.addWorldAxis()
        tubeSceneViewModel.rotateParentNode()
        tubeSceneViewModel.zoomScene()
        tubeSceneViewModel.publishScene()
    }
    
    func renderNewScene1(){
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
    
    func closeView(){
        dismiss()
    }
    
    var body:some View{
        AppBackgroundStack(content: {
            modelPage
        })
        .navigationBarBackButtonHidden()
        .onChange(of: activeModelSheet){ item in
            if let item{
                activeModelSheet = nil
                switch item{
                case ActiveModelSheet.OPEN_MODEL_SETTINGS:
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
                Button(action: { activeModelSheet = .OPEN_MODEL_SETTINGS }) {
                    Image(systemName: "gear")
                }
                .toolbarFontAndPadding()
            }
            ToolbarItem(placement: .principal) {
                Button(action: closeView){
                    ZStack{
                        Image(systemName: "arrow.triangle.2.circlepath").font(.title).foregroundColor(.systemBlue)
                        Image(systemName: "view.2d").imageScale(.small).foregroundColor(.systemBlue)
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
