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
    @State var showConfirmationDialog:Bool = false
    @State private var toast: Toast? = nil
    @State var image:Image?
    let message:Message
    let userName:String
    
    let confStr = "Message will be permantly deleted, proceed?"
    
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
        Button(action: { showConfirmationDialog.toggle() } ){
            Text("Delete")
        }
        .disabled(!allowedToDelete)
        .buttonStyle(ButtonStyleFillListRow(
            lblColor: allowedToDelete ? Color.systemRed : Color.systemRed.opacity(0.3)))
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
    
    var topMenu:  some View{
        VStack{
            BackButton(title: userName).hLeading()
            Divider().overlay{ Color.white}.hLeading()
        }
        .frame(height:MENU_HEIGHT)
        .padding()
   }
    
    var messageData:some View{
        List{
            userSentTube
            userSentImage
            buttons
        }
        .listStyle(.automatic)
    }
    
    var mainPage:some View{
        VStack(spacing:0){
            topMenu
            messageData
            .task{ loadImageFromStorage() }
        }
    }
    
    var body:some View{
        AppBackgroundStack(content: {
            mainPage
        })
        .onDisappear{ image = nil }
        .toastView(toast: $toast)
        .confirmationDialog("Attention!",
                            isPresented: $showConfirmationDialog,
                            titleVisibility: .visible){
                buttonsConfirmation
        } message: {
            Text(confStr)
        }
        .modifier(NavigationViewModifier(title: ""))
    }
    
    var buttonsConfirmation:some View{
        VStack{
            Button("Yes, delete",role: .destructive) {
                deleteMessageFromFirebase()
            }
            Button("Cancel", role: .cancel){}
        }
        
    }
    
    func loadImageFromStorage(){
        if let storageId = message.storageId,
           let groupid = message.groupId{
             firestoreViewModel.downloadImageFromStorage(groupId: groupid, storageId: storageId){ (error,uiImage) in
                 if let uiImage = uiImage{
                     self.image = Image(uiImage: uiImage)
                }
            }
        }
    }
    
    func loadViewModelWithSharedTube(){
        if let sharedTube = message.sharedTube{
            if tubeViewModel.initViewFromSharedValues(sharedTube){
                tubeViewModel.rebuild()
                navigationViewModel.navTo(.HOME)
                closeView()
            }
            else{
                toast = Toast(style: .error, message: "Failed to load tube!")
            }
        }
    }
    
    func deleteMessageFromFirebase(){
        if(!allowedToDelete){ return }
        guard let groupId = message.groupId,
              let messagId = message.id
        else { return }
        
        firestoreViewModel.removeMessageFromGroup(groupId,
                                                  messageId: messagId,
                                                  storageId:message.storageId){ result in
            if(!result.isSuccess){ toast = Toast(style: .error, message: "Failed to delete message!") }
            else{ self.closeView()}
        }
    }
    
    func closeView(){
        dismiss()
    }
    
}
