//
//  AttachmentView.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-09-03.
//

import SwiftUI

struct AttachVar{
    var showConfirmationDialog:Bool = false
    var toast: Toast? = nil
    var image:Image?
    var alreadySaved:Bool = false
    var isSaving:Bool = false
}

struct AttachmentView:View{
    @EnvironmentObject var firestoreViewModel: FirestoreViewModel
    @EnvironmentObject var navigationViewModel: NavigationViewModel
    @EnvironmentObject var tubeViewModel: TubeViewModel
    @Environment(\.dismiss) private var dismiss
    @State var aVar:AttachVar = AttachVar()
    let message:Message
    let title:String
    let contactDisplayName:String?
    let confStr = "Message will be permantly deleted, proceed?"
    
    var allowedToDelete:Bool{
        guard let from = message.senderId,
              let currentUserID = firestoreViewModel.currentUserID
        else{ return false }
        return from == currentUserID
    }
    
    var notAllowedToSave:Bool{
        aVar.alreadySaved||aVar.isSaving
    }
    
    var attachmentLabel:some View{
        Text(title)
        .font(.callout)
        .bold()
        .foregroundStyle(.black)
        .hLeading()
        .padding([.leading])
    }
    
    var saveButton:some View{
        Button(action: saveSharedTubeToDevice ){
            buttonAsNavigationLink(title: "Save to storage",
                                   systemImage: "arrow.down.doc",
                                   lblColor: notAllowedToSave ? Color.black.opacity(0.3) : Color.systemBlue)
        }
        .buttonStyle(ButtonStyleFillListRow())
        .disabled(notAllowedToSave)
    }
    
    var loadButton:some View{
        Button(action: loadViewModelWithSharedTube ){
            buttonAsNavigationLink(title: "Load tubemodel",
                                   systemImage: "arrow.up.circle",
                                   lblColor: .systemBlue)
       }
        .buttonStyle(ButtonStyleFillListRow())
    }
    
    var deleteButton:some View{
        Button(action: { aVar.showConfirmationDialog.toggle() } ){
            buttonAsNavigationLink(title: "Delete message",
                                   systemImage: "minus.circle",
                                   lblColor: allowedToDelete ? Color.systemRed : Color.systemRed.opacity(0.3))
        }
        .buttonStyle(ButtonStyleFillListRow())
        .disabled(!allowedToDelete)
   }
    
    var buttons:some View{
        return Section(content:{
            VStack(spacing:10){
                saveButton
                Divider()
                loadButton
                Divider()
                deleteButton
            }},
            header: {Text("Action:").listSectionHeader()}) {
            
        }
        
    }
    
    @ViewBuilder
    var userSentImage:some View{
        if aVar.image != nil{
            Section(content:{
                aVar.image?
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
            HStack{
                Text("Attached tube")
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .hLeading()
                BackButton(title: title,imgLabel: "arrow.down")
            }
            Divider()
        }
        .frame(height:MENU_HEIGHT)
        .padding([.leading,.trailing,.top])
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
        AppBackgroundSheetStack(content: {
            mainPage
        })
        .task {
            validateIfTubeIsAlreadyStored()
        }
        .onDisappear{ aVar.image = nil }
        .toastView(toast: $aVar.toast)
        .confirmationDialog("Attention!",
                            isPresented: $aVar.showConfirmationDialog,
                            titleVisibility: .visible){
                buttonsConfirmation
        } message: {
            Text(confStr)
        }
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
                     self.aVar.image = Image(uiImage: uiImage)
                }
            }
        }
    }
    
    func loadViewModelWithSharedTube(){
        if let sharedTube = message.sharedTube{
            if tubeViewModel.initViewFromSharedValues(sharedTube){
                tubeViewModel.rebuild()
                navigationViewModel.navTo(.MODEL_2D)
                closeView()
            }
            else{
                aVar.toast = Toast(style: .error, message: "Failed to load tube!")
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
            if(!result.isSuccess){ aVar.toast = Toast(style: .error, message: "Failed to delete message!") }
            else{ self.closeView()}
        }
    }
    
    func saveSharedTubeToDevice(){
        if(notAllowedToSave){ return }
        aVar.isSaving = true
        if let sharedTube = message.sharedTube{
            if saveSharedTube(sharedTube){
                aVar.toast = Toast(style: .success, message: "Tube saved!")
                aVar.alreadySaved = true
                return
            }
        }
        aVar.toast = Toast(style: .error, message: "Failed to save tube!")
        aVar.isSaving = false
    }
    
    func saveSharedTube(_ tube:SharedTube) -> Bool{
        let managedObjectContext = PersistenceController.shared.container.viewContext
        let model = TubeModel(context:managedObjectContext)
        let details = inspectSenderRecieverFromMessage(message)
        let title = details.sentBySelf ?
        "Sent to \(details.to) on \(message.date?.toISO8601String() ?? "00:00:00")" :
        "Recieved from \(details.from) \(message.date?.toISO8601String() ?? "00:00:00")"
        if tubeViewModel.buildModelFromSharedTube(model,
                                               sharedTube: tube,
                                               date:message.date,
                                               id:message.id,
                                               message:message.message,
                                               from:details.from,
                                               title: title){
            do{
                try PersistenceController.saveContext()
                return true
            }
            catch{
                return false
            }
        }
        return false
    }
    
    func inspectSenderRecieverFromMessage(_ message:Message) -> (from:String,to:String,sentBySelf:Bool){
        if let from = message.senderId,
           let currentUserID = firestoreViewModel.currentUserID{
            if from == currentUserID{
                return (from:USER_IDENTIFIER_COREDATA,to:contactDisplayName ?? "",sentBySelf:true)
            }
            return (from:contactDisplayName ?? "",to:firestoreViewModel.currentUserDisplayName,sentBySelf:false)
        }
        return (from:"",to:"",sentBySelf:true)
    }
    
    func validateIfTubeIsAlreadyStored(){
        aVar.alreadySaved = PersistenceController.fetchTubeCountById(message.id) > 0
    }
    
    func closeView(){
        dismiss()
    }
    
}
