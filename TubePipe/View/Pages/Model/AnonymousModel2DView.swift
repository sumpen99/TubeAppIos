//
//  AnonymousHomeView.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-11-01.
//
import SwiftUI

enum ActiveAnonymousHomeSheet: Identifiable {
    case OPEN_TUBE_SETTINGS
    case OPEN_TUBE_DOCUMENT
    case OPEN_TUBE_SAVE
    case OPEN_TUBE_INFORMATION
    
    var id: Int {
        hashValue
    }
}

struct AnonymousModel2DView: View{
    @EnvironmentObject var tubeViewModel: TubeViewModel
    @State var activeHomeSheet: ActiveAnonymousHomeSheet?
    var body: some View{
        NavigationStack{
            AppBackgroundStack(content: {
                TubeView(tubeInteraction: .IS_MOVEABLE)
            })
            .onChange(of: activeHomeSheet){ item in
                 if let item{
                     activeHomeSheet = nil
                     switch item{
                     case ActiveAnonymousHomeSheet.OPEN_TUBE_SETTINGS:
                         SheetPresentView(style: .detents([.medium()])){
                             TubeSettingsView()
                                 .environmentObject(tubeViewModel)
                         }
                         .makeUIView()
                     case ActiveAnonymousHomeSheet.OPEN_TUBE_DOCUMENT:
                         SheetPresentView(style: .sheet){
                             TubeDocumentView()
                                 .environmentObject(tubeViewModel)
                         }
                         .makeUIView()
                     case ActiveAnonymousHomeSheet.OPEN_TUBE_SAVE:
                         SheetPresentView(style: .sheet){
                             SaveDocumentView()
                                 .environmentObject(tubeViewModel)
                         }
                         .makeUIView()
                     case ActiveAnonymousHomeSheet.OPEN_TUBE_INFORMATION:
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
                 ToolbarItem(placement: .principal) {
                     navModel3DButton
                 }
                 ToolbarItem(placement: .navigationBarTrailing) {
                     Menu{
                         navPrintButton.padding()
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
    
    var navModel3DButton:some View{
        NavigationLink(destination:LazyDestination(destination: {
            Model3DView()
        })){
            ZStack{
                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(.title)
                    .foregroundStyle(Color.systemBlue)
                Image(systemName: "view.3d")
                    .imageScale(.small)
                    .foregroundStyle(Color.systemBlue)
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
    
    var navSaveButton:some View{
        Button(action: { activeHomeSheet = .OPEN_TUBE_SAVE } ){
            Label("Save", systemImage: "arrow.down.doc")
        }
    }
    
    var navInfoButton:some View{
        Button(action: { activeHomeSheet = .OPEN_TUBE_INFORMATION } ){
            Label("Help", systemImage: "info.circle")
        }
    }
}

