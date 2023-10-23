//
//  AttachmentView.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-09-03.
//

import SwiftUI

struct AttachmentView:View{
    @EnvironmentObject var firestoreViewModel: FirestoreViewModel
    @EnvironmentObject var navigationViewModel: NavigationViewModel
    @EnvironmentObject var tubeViewModel: TubeViewModel
    @Environment(\.dismiss) private var dismiss
    @State var image:Image?
    let message:Message
    let userName:String
    
    var allowedToDelete:Bool{
        guard let from = message.senderId,
              let currentUserID = firestoreViewModel.currentUserID
        else{ return false }
        return from == currentUserID
    }
    
    var loadButton:some View{
        Button(action: loadViewModelWithSharedTube ){
            Text("Load Tube")
        }
        .buttonStyle(ButtonStyleFillListRow(lblColor: Color.systemBlue))
    }
    
    var deleteButton:some View{
        Button(action: {
        } ){
            Text("Delete")
        }
        .disabled(!allowedToDelete)
        .buttonStyle(ButtonStyleFillListRow(lblColor: Color.systemRed))
    }
    
    var buttons:some View{
        return Section(content:{
            VStack(spacing:10){
                loadButton
                Divider()
                deleteButton
            }},
            header: {Text("Action:").listSectionHeader()}) {
            
        }
        
    }
    
    @ViewBuilder
    var userSentImage:some View{
        if image != nil{
            Section(content:{
                image?
                .resizable()
                .scaledToFit()
                
            },
                header: {Text("Attached Photo:").listSectionHeader(color: Color.white)}) {
            }
        }
        
    }
    
    @ViewBuilder
    var userSentTube:some View{
        if let sharedTube = message.sharedTube{
            SharedTubeSummary(sharedTube: sharedTube)
        }
    }
    
    var mainPage:some View{
        List{
            userSentTube
            userSentImage
            buttons
        }
        .listStyle(.automatic)
    }
    
    var topMenu:  some View{
        VStack{
            BackButton(title: userName).hLeading()
            Divider().overlay{ Color.white}.hLeading()
        }
        .frame(height:MENU_HEIGHT)
        .padding()
   }
    
    var body:some View{
        AppBackgroundStack(content: {
            VStack(spacing:0){
                topMenu
                mainPage
                .onAppear{ loadImageFromStorage() }
            }
            
        })
        .modifier(NavigationViewModifier(title: ""))
    }
    
    func loadImageFromStorage(){
        if let storageId = message.storageId,
           let groupid = message.groupId{
            firestoreViewModel.downloadImageFromStorage(groupId: groupid, storageId: storageId){ (error,uiImage) in
                 if let uiImage = uiImage{
                    self.image = Image(uiImage: uiImage)
                }
                else{
                    debugLog(object: error?.localizedDescription ?? "")
                }
                
            }
        }
    }
    
    func loadViewModelWithSharedTube(){
        if let sharedTube = message.sharedTube{
            if tubeViewModel.initViewFromSharedValues(sharedTube){
                tubeViewModel.rebuild()
                navigationViewModel.navTo(.HOME)
            }
        }
    }
    
    func closeView(){
        dismiss()
    }
    
}
