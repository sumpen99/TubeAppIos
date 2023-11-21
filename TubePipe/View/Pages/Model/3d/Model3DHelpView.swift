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
                    .frame(width:100,height:100)
                    .hCenter()
                } header: {
                    Text("One-Finger-Pan").listSectionHeader()
                } footer: {
                    Text("Pan with one finger to rotate the camera around the tube").listSectionFooter()
                } .listRowBackground(Color.lightText)
                Section {
                    Image("two-finger-move")
                    .resizable()
                    .frame(width:100,height:100)
                    .hCenter()
                } header: {
                    Text("Two-Finger-Pan").listSectionHeader()
                } footer: {
                    Text("Pan with two fingers to move the tube around in the screen").listSectionFooter()
                } .listRowBackground(Color.lightText)
                Section {
                    Image("two-finger-rotate")
                    .resizable()
                    .frame(width:100,height:100)
                    .hCenter()
                } header: {
                    Text("Two-Finger-Rotate").listSectionHeader()
                } footer: {
                    Text("Rotate with two fingers to roll the tube").listSectionFooter()
                } .listRowBackground(Color.lightText)
                Section {
                    Image("two-finger-zoom")
                    .resizable()
                    .frame(width:100,height:100)
                    .hCenter()
                } header: {
                    Text("Two-Finger-Zoom").listSectionHeader()
                } footer: {
                    Text("Pinch to zoom in-out on the tube").listSectionFooter()
                } .listRowBackground(Color.lightText)
            }
            .scrollContentBackground(.hidden)
        }
    }
    
}
