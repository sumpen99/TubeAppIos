//
//  AnonymousHomeView.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-11-01.
//
import SwiftUI
struct AnonymousHomeView: View{
    @EnvironmentObject var tubeViewModel: TubeViewModel
    @State var activeHomeSheet: ActiveHomeSheet?
    var body: some View{
        NavigationView{
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
                        SheetPresentView(style: .detents([.medium(),.large()])){
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
                   case ActiveHomeSheet.OPEN_TUBE_INFORMATION:
                        SheetPresentView(style: .sheet){
                            TubeHelpView()
                        }
                        .makeUIView()
                    default: break
                    }
                }
            }
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
                case ActiveHomeSheet.OPEN_TUBE_INFORMATION:
                    TubeHelpView()
                default:EmptyView()
                }
            }*/
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { activeHomeSheet = .OPEN_TUBE_SETTINGS }) {
                        Image(systemName: "ruler")
                    }
                    .toolbarFontAndPadding()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu{
                        navPrintButton
                        navSaveButton
                        navInfoButton
                    }
                    label:{
                        Label("Info",systemImage: "ellipsis")
                        .toolbarFontAndPadding()
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
   
    var navInfoButton:some View{
        Button(action: { activeHomeSheet = .OPEN_TUBE_INFORMATION } ){
            Label("Help", systemImage: "info.circle")
        }
    }
}

