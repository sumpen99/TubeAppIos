//
//  TubeHelpView.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-07-10.
//

import SwiftUI

struct TubeHelpView: View{
    @Environment(\.dismiss) private var dismiss
    @State var currentMagnification = 1.0
    @State var currentRotation = Angle.zero
    @State var location = CGPoint()
    
    
    var body:some View{
        VStack(spacing:0){
            TopMenu(title: "Information", actionCloseButton: closeView)
            helpBody
        }
        .modifier(HalfSheetModifier())
    }
    
    var helpBody: some View{
        VStack(spacing:10){
            List{
                Section {
                    Image("tubeskiss_3")
                        .resizable()
                        .scaledToFill()
                } header: {
                    Text("Measurement").listSectionHeader()
                } footer: {
                    Text("Measure radius from center of tube. To optimize user experience choosen unit in TubePipe ( for all settingsvalues ) is set to millimeters. In reality though any will do. ")
                }.listRowBackground(Color.lightText)
           }
           .scrollDisabled(true)
           .scrollContentBackground(.hidden)
        }
    }
    
    //MARK: - BUTTON FUNCTIONS
    func closeView(){
        dismiss()
    }
    
}
