//
//  AnonymousHomeView.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-11-01.
//
import SwiftUI
struct AnonymousModel2DView: View{
    @EnvironmentObject var tubeViewModel: TubeViewModel
    @State var activeHomeSheet: ActiveHomeSheet?
    var body: some View{
        NavigationStack{
            AppBackgroundStack(content: {
                TubeView(tubeInteraction: .IS_MOVEABLE)
            })
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    navOpenTubeSettingsButton
                }
                ToolbarItem(placement: .principal) {
                    navModel3DButton
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu{
                        navPrintButton
                        navInfoButton
                    }
                    label:{
                        Label("Info",systemImage: "ellipsis")
                        .toolbarFontAndPadding()
                    }
                    
                    
                }
            }
            .onAppear{
                tubeViewModel.initFromCache()
            }
            .onChange(of: activeHomeSheet){ item in
                if let item{
                    activeHomeSheet = nil
                    switch item{
                    case ActiveHomeSheet.OPEN_TUBE_SETTINGS:
                        SheetPresentView(style: .detents([.medium(),.large()])){
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
                   case ActiveHomeSheet.OPEN_TUBE_INFORMATION:
                        SheetPresentView(style: .sheet){
                            TubeHelpView()
                        }
                        .makeUIView()
                    default: break
                    }
                }
            }
        }
        
    }
    
    var navModel3DButton:some View{
        NavigationLink(destination:LazyDestination(destination: {
            Model3DView()
        })){
            ZStack{
                Image(systemName: "arrow.triangle.2.circlepath").font(.title).foregroundColor(.systemBlue)
                Image(systemName: "view.3d").imageScale(.small).foregroundColor(.systemBlue)
            }
        }
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
   
    var navInfoButton:some View{
        Button(action: { activeHomeSheet = .OPEN_TUBE_INFORMATION } ){
            Label("Help", systemImage: "info.circle")
        }
    }
}

