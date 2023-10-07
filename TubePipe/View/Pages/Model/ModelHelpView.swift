//
//  ModelHelpView.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-10-07.
//

import SwiftUI

struct ModelHelpView: View{
    
    
    var body:some View{
        NavigationView{
            AppBackgroundStack(content: {
                helpBody
            })
            .modifier(NavigationViewModifier(title: ""))
        }
        .hiddenBackButtonWithCustomTitle("Model")
    }
    
    var helpBody: some View{
        VStack{
            List{
                Section(header: Text("One-Finger-Pan").listSectionHeader(),
                        footer: Text("Pan with one finger to rotate the camera around the tube").listSectionFooter()){
                    Image("one-finger-rotate")
                        .resizable()
                        .scaledToFit()
                 }
                Section(header: Text("Two-Finger-Pan").listSectionHeader(),
                        footer: Text("Pan with two fingers to move the tube around in the screen").listSectionFooter()){
                    Image("two-finger-move")
                        .resizable()
                        .scaledToFit()
                 }
                Section(header: Text("Two-Finger-Rotate").listSectionHeader(),
                        footer: Text("Rotate with two fingers to roll the tube").listSectionFooter()) {
                    Image("two-finger-rotate")
                        .resizable()
                        .scaledToFit()
                 }
                Section(header: Text("Two-Finger-Zoom").listSectionHeader(),
                        footer: Text("Pinch to zoom in-out on the tube").listSectionFooter()) {
                    Image("two-finger-zoom")
                        .resizable()
                        .scaledToFit()
                 }
           }
           .scrollContentBackground(.hidden)
        }
    }
    
}
