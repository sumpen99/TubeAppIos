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
    
    var id: Int {
        hashValue
    }
}

struct HomeView: View{
    @State var activeHomeSheet: ActiveHomeSheet?
    var body: some View{
        NavigationView{
            AppBackgroundStack(content: {
                TubeView()
            })
            .modifier(NavigationViewModifier(title: ""))
            .sheet(item: $activeHomeSheet){ item in
                switch item{
                case ActiveHomeSheet.OPEN_TUBE_SETTINGS:
                    TubeSettingsView()
                        .presentationDragIndicator(.visible)
                        .presentationDetents([.medium])
                case ActiveHomeSheet.OPEN_TUBE_DOCUMENT:
                                    TubeDocumentView()
                                        .presentationDragIndicator(.visible)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { activeHomeSheet = .OPEN_TUBE_SETTINGS }) {
                        Image(systemName: "ruler")
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { activeHomeSheet = .OPEN_TUBE_DOCUMENT }) {
                        Image(systemName: "doc")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination:LazyDestination(destination: {
                        TubeHelpView()
                    })){
                        Image(systemName: "info.circle")
                    }
                }
            }
        }
        
    }
}
