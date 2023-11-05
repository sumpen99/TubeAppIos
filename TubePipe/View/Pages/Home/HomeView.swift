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

struct HomeView: View{
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
            
            // PREFFERED BUT LEAKS ON IOS_17
            /*.sheet(item: $activeHomeSheet){ item in
                switch item{
                case ActiveHomeSheet.OPEN_TUBE_SETTINGS:
                    TubeSettingsView()
                    .presentationDragIndicator(.visible)
                    .presentationDetents([.medium])
                case ActiveHomeSheet.OPEN_TUBE_DOCUMENT:
                    TubeDocumentView()
                case ActiveHomeSheet.OPEN_TUBE_SAVE:
                    SaveDocumentView()
                case ActiveHomeSheet.OPEN_TUBE_SHARE:
                    ShareDocumentView()
                case ActiveHomeSheet.OPEN_TUBE_INFORMATION:
                    TubeHelpView()
                }
            }*/
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { activeHomeSheet = .OPEN_TUBE_SETTINGS }) {
                        Image(systemName: "ruler")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu{
                        navPrintButton
                        navShareButton
                        navSaveButton
                        navInfoButton
                    }
                    label:{
                        Label("Info",systemImage: "ellipsis")
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
   }
    
    var navInfoButton:some View{
        Button(action: { activeHomeSheet = .OPEN_TUBE_INFORMATION } ){
            Label("Help", systemImage: "info.circle")
        }
    }
}
