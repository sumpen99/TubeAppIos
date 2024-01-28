//
//  ConstructView.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-06-10.
//

import SwiftUI
 
enum ActiveHomeSheet: Identifiable {
    case OPEN_TUBE_SETTINGS
    case OPEN_TUBE_DOCUMENT
    case OPEN_TUBE_SAVE
    case OPEN_TUBE_SHARE
    case OPEN_TUBE_INFORMATION
    
    var id: Int {
        hashValue
    }
}

enum ModelRoute: Identifiable{
    case ROUTE_3D
    case ROUTE_AR
    
    var id: Int {
        hashValue
    }
    
}

struct Model2DView: View{
    @EnvironmentObject var navigationViewModel: NavigationViewModel
    @EnvironmentObject var tubeViewModel: TubeViewModel
    @EnvironmentObject var firestoreViewModel: FirestoreViewModel
    @State var activeHomeSheet: ActiveHomeSheet?
   
    var body: some View{
        NavigationStack(path:$navigationViewModel.pathTo){
            AppBackgroundStack(content: {
                TubeView(tubeInteraction: .IS_MOVEABLE)
            })
            .navigationDestination(for: ModelRoute.self){  route in
                switch route{
                case .ROUTE_3D:         Model3DView()
                case .ROUTE_AR:         ModelArView()
                }
            }
           .onChange(of: activeHomeSheet){ item in
                if let item{
                    activeHomeSheet = nil
                    switch item{
                    case ActiveHomeSheet.OPEN_TUBE_SETTINGS:
                        SheetPresentView(style: .detents([.medium()])){
                            TubeSettingsView()
                                .environmentObject(tubeViewModel)
                        }
                        .makeUIView()
                    case ActiveHomeSheet.OPEN_TUBE_DOCUMENT:
                        SheetPresentView(style: .sheet){
                            TubeDocumentView()
                                .environmentObject(tubeViewModel)
                        }
                        .makeUIView()
                    case ActiveHomeSheet.OPEN_TUBE_SAVE:
                        SheetPresentView(style: .sheet){
                            SaveDocumentView()
                                .environmentObject(tubeViewModel)
                        }
                        .makeUIView()
                    case ActiveHomeSheet.OPEN_TUBE_SHARE:
                        SheetPresentView(style: .sheet){
                            ShareDocumentView()
                                .environmentObject(tubeViewModel)
                                .environmentObject(firestoreViewModel)
                        }
                        .makeUIView()
                    case ActiveHomeSheet.OPEN_TUBE_INFORMATION:
                        SheetPresentView(style: .sheet){
                            TubeHelpView()
                        }
                        .makeUIView()
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    navOpenTubeSettingsButton
                }
                ToolbarItemGroup(placement: .principal){
                    HStack{
                        navModel3DButton
                        navModelARButton
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu{
                        navPrintButton.padding()
                        navShareButton.padding()
                        navSaveButton.padding()
                        navInfoButton.padding()
                    }
                label:{
                    Image(systemName: "ellipsis.circle").toolbarFontAndPadding()
                }
                }
                
            }
        }
    }
    
    var navModelARButton:some View{
        Button(action: { navigationViewModel.switchPathToRoute(ModelRoute.ROUTE_AR)}, label: {
            ZStack{
                Image(systemName: "arrow.triangle.2.circlepath").font(.title).foregroundStyle(Color.systemBlue)
                Image(systemName: "camera.metering.multispot").imageScale(.small).foregroundStyle(Color.systemBlue)
            }
        })
        .toolbarFontAndPadding()
    }
    
    var navModel3DButton:some View{
        Button(action: { navigationViewModel.switchPathToRoute(ModelRoute.ROUTE_3D)}, label: {
            ZStack{
                Image(systemName: "arrow.triangle.2.circlepath").font(.title).foregroundStyle(Color.systemBlue)
                Image(systemName: "view.3d").imageScale(.small).foregroundStyle(Color.systemBlue)
            }
        })
        .toolbarFontAndPadding()
    }
    
    var navOpenTubeSettingsButton:some View{
        Button(action: { activeHomeSheet = .OPEN_TUBE_SETTINGS }) {
            Image(systemName: "gear")
        }
        .toolbarFontAndPadding()
    }
    
    var navPrintButton:some View{
        Button(action: { activeHomeSheet = .OPEN_TUBE_DOCUMENT } ){
            Label("Document", systemImage: "doc")
        }
    }
    
    var navSaveButton:some View{
        Button(action: { activeHomeSheet = .OPEN_TUBE_SAVE } ){
            Label("Save", systemImage: "arrow.down.doc")
        }
    }
    
    var navShareButton:some View{
        Button(action: { activeHomeSheet = .OPEN_TUBE_SHARE } ){
            Label("Share", systemImage: "arrowshape.turn.up.right")
        }
        .opacity(firestoreViewModel.isCurrentUserPublic ? 1.0 : 0.3)
        .disabled(!firestoreViewModel.isCurrentUserPublic)
   }
    
    var navInfoButton:some View{
        Button(action: { activeHomeSheet = .OPEN_TUBE_INFORMATION } ){
            Label("Help", systemImage: "info.circle")
        }
    }
}
