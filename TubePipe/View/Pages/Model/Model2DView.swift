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

struct Model2DView: View{
    @EnvironmentObject var tubeViewModel: TubeViewModel
    @EnvironmentObject var firestoreViewModel: FirestoreViewModel
    @State var activeHomeSheet: ActiveHomeSheet?
   
    var body: some View{
        NavigationStack{
            AppBackgroundStack(content: {
                TubeView(tubeInteraction: .IS_MOVEABLE)
            })
            .onAppear{
                tubeViewModel.initFromCache()
            }
            .onChange(of: activeHomeSheet){ item in
                if let item{
                    activeHomeSheet = nil
                    switch item{
                    case ActiveHomeSheet.OPEN_TUBE_SETTINGS:
                        SheetPresentView(style: .detents([.medium()])){
                            TubeSettingsView()
                                .environmentObject(tubeViewModel)
                                .presentationDragIndicator(.visible)
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
                    Button(action: { activeHomeSheet = .OPEN_TUBE_SETTINGS }) {
                        Image(systemName: "gear")
                    }
                    .toolbarFontAndPadding()
                }
                ToolbarItem(placement: .principal) {
                    NavigationLink(destination:LazyDestination(destination: {
                        Model3DView()
                    })){
                        ZStack{
                            Image(systemName: "arrow.triangle.2.circlepath").imageScale(.large).foregroundColor(.black)
                            Image(systemName: "view.3d").imageScale(.small).foregroundColor(.systemBlue)
                        }
                    }
                    .toolbarFontAndPadding()
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
