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
    
    var saveButton:some View{
        Button(action: saveSharedTubeToDevice ){
            HStack{
                Text("Save").hCenter()
                Image(systemName: "arrow.down.doc")
            }
        }
        .disabled(notAllowedToSave)
        .buttonStyle(ButtonStyleFillListRow(
            lblColor: notAllowedToSave ? Color.black.opacity(0.3) : Color.systemBlue))
    }
    
    var loadButton:some View{
        Button(action: loadViewModelWithSharedTube ){
            HStack{
                Text("Load").hCenter()
                Image(systemName: "arrow.triangle.2.circlepath.circle")
            }
       }
        .buttonStyle(ButtonStyleFillListRow(lblColor: Color.systemBlue))
    }
    
    var deleteButton:some View{
        Button(action: { aVar.showConfirmationDialog.toggle() } ){
            HStack{
                Text("Delete").hCenter()
                Image(systemName: "trash")
            }
        }
        .disabled(!allowedToDelete)
        .buttonStyle(ButtonStyleFillListRow(
            lblColor: allowedToDelete ? Color.systemRed : Color.systemRed.opacity(0.3)))
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
                Text(title).font(.headline)
                    .foregroundStyle(.primary)
                    .lineLimit(1).hLeading()
                BackButton(title: title,imgLabel: "arrow.down")
            }
            Divider()
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
        "Originated from message sent to \(details.to)) on \(message.date?.toISO8601String() ?? "00:00:00")" :
        "Originated from message recieved from \(details.from)) \(message.date?.toISO8601String() ?? "00:00:00")"
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
