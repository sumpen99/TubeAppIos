//
//  ModelHelpView.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-10-07.
//

import SwiftUI

struct Model3DHelpView: View{
    
    
    var body:some View{
        AppBackgroundStack(content: {
            helpBody
        })
        .hiddenBackButtonWithCustomTitle("Model")
    }
    
    var helpBody: some View{
        VStack{
            List{
                Section {
                    Image("one-finger-rotate")
                    .resizable()
                    .scaledToFit()
                } header: {
                    Text("One-Finger-Pan").listSectionHeader()
                } footer: {
                    Text("Pan with one finger to rotate the camera around the tube").listSectionFooter()
                } .listRowBackground(Color.clear)
                Section {
                    Image("two-finger-move")
                        .resizable()
                        .scaledToFit()
                } header: {
                    Text("Two-Finger-Pan").listSectionHeader()
                } footer: {
                    Text("Pan with two fingers to move the tube around in the screen").listSectionFooter()
                } .listRowBackground(Color.clear)
                Section {
                    Image("two-finger-rotate")
                        .resizable()
                        .scaledToFit()
                } header: {
                    Text("Two-Finger-Rotate").listSectionHeader()
                } footer: {
                    Text("Rotate with two fingers to roll the tube").listSectionFooter()
                } .listRowBackground(Color.clear)
                Section {
                    Image("two-finger-zoom")
                        .resizable()
                        .scaledToFit()
                } header: {
                    Text("Two-Finger-Zoom").listSectionHeader()
                } footer: {
                    Text("Pinch to zoom in-out on the tube").listSectionFooter()
                } .listRowBackground(Color.clear)
            }
            .scrollContentBackground(.hidden)
        }
    }
    
}
