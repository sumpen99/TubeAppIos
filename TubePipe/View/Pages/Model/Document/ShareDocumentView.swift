//
//  ShareDocumentView.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-08-21.
//

import SwiftUI

struct SortedContactListVar{
    var isSuggestionShowing:Bool = false
    var showingOptions:Bool = false
    var currentContact:Contact?
}

struct ShareDocumentView:View{
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var firestoreViewModel: FirestoreViewModel
    @EnvironmentObject var globalLoadingPresentation: GlobalLoadingPresentation
    @EnvironmentObject var tubeViewModel: TubeViewModel
    @State var docContent:DocumentContent = DocumentContent()
    @State var sclVar: SortedContactListVar = SortedContactListVar()
    @State private var toast: Toast? = nil
  
    var buttonIsDisabled:Bool{
        docContent.isSaving||(sclVar.currentContact == nil || docContent.message.isEmpty)
    }
    
    @ViewBuilder
    var toogleContactsButton:some View{
        Image(systemName: sclVar.isSuggestionShowing ? "chevron.down" : "chevron.right")
        .hTrailing()
    }
    
    var shareButton: some View{
        Button(action:startSendingMessageProcess,label: {
            Text("Send")
        })
        .disabled(buttonIsDisabled)
        .opacity(buttonIsDisabled ? 0.2 : 1.0)
        .foregroundColor(buttonIsDisabled ? .black : .systemBlue)
        .font(.title2)
        .bold()
        .hTrailing()
    }
    
    
    var suggestionsList: some View{
        SortedContactsList(currentContact:$sclVar.currentContact,
                           showingOptions: $sclVar.showingOptions,
                           contactCardOption: .CONTACT_CARD_TAP_ON_CARD,
                           contactSectionOption: .SHARE_DOCUMENT_VIEW_SECTION,
                           contactAvatarColor: .black,
                           contactInfoColor: .black)
        .frame(maxWidth: .infinity,
               minHeight: 0,
               maxHeight: 100 * CGFloat(min(3,firestoreViewModel.confirmedContacts.count)))
    }
    
    @ViewBuilder
    var contactField:some View{
        HStack{
            Label("Send to: ",systemImage: "person.crop.square")
             toogleContactsButton
            
        }
        .hLeading()
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation{
                sclVar.isSuggestionShowing.toggle()
            }
        }
        Divider()
        if sclVar.isSuggestionShowing{
            suggestionsList
        }
    }
    
    @ViewBuilder
    var clearContactField:some View{
        if sclVar.currentContact != nil{
            HStack{
                let initial = sclVar.currentContact?.initial ?? ""
                Label(sclVar.currentContact?.displayName ?? "",
                      systemImage: "bubbles.and.sparkles")
                .font(.headline)
                .bold()
                .foregroundColor(Color[initial])
                .hLeading()
                Button(action: { withAnimation{ sclVar.currentContact = nil } }){
                    Image(systemName: "xmark")
                    .foregroundColor(.red)
                }
            }
            .hLeading()
            .padding(.top)
        }
    }
    
    var reciever: some View{
        VStack(spacing: 5.0){
            contactField
            clearContactField
        }
        .halfSheetWhitePadding()
        .padding(.top)
    }
    
    var mainContent:some View{
        VStack(spacing:10){
            ScrollView{
                VStack(spacing:20){
                    reciever
                    BaseTubeTextField(docContent: $docContent,placeHolder:"Add a message or subject to share with friend")
                }
            }
            .scrollDisabled(true)
        }
        .padding([.leading,.trailing])
    }
    
    var body: some View{
        VStack(spacing:0){
            TopMenu(title: "Share document", actionCloseButton: closeView)
            Section {
                mainContent
            } header:{
                Text(Date().formattedString()).sectionTextSecondary(color:.darkGray).padding(.leading)
            }
        }
        .onSubmit { startSendingMessageProcess() }
        .submitLabel(.send)
        .toastView(toast: $toast)
        .onChange(of: sclVar.showingOptions){ value in
           withAnimation{ sclVar.isSuggestionShowing.toggle() }
            
        }
        .halfSheetBackgroundStyle()
    }
    
    //MARK: - BUTTON FUNCTIONS
     func closeView(){
        dismiss()
    }
    
    func startSendingMessageProcess(){
        if buttonIsDisabled{ return }
        docContent.isSaving = true
        guard let contact = sclVar.currentContact,
              let senderId = firestoreViewModel.currentUserID,
              let groupId = firestoreViewModel.getGroupIdFromOtherUserId(contact.userId)
        else { return }
        
        let messageId = docContent.documentId
        let storageId = docContent.storageId
        
        sendMessage(groupId:groupId,
                    senderId:senderId,
                    messageId: messageId,
                    storageId: storageId){ result in
            closeAfterToast(isSuccess: result.isSuccess,msg: "Message sent!",toast: &toast,action: closeView)
            docContent.isSaving = false
        }
    }
    
    func sendMessage(groupId:String,
                     senderId:String,
                     messageId:String,
                     storageId:String?,
                     onResult:((ResultOfOperation) ->Void)? = nil){
       docContent.trim()
       let message = Message(messageId: messageId,
                              groupId: groupId,
                              senderId: senderId,
                              message: docContent.message,
                              sharedTube: tubeViewModel.buildSharedTubeFromCurrentValues(),
                              date: Date(),
                              storageId: storageId)
        
        firestoreViewModel.sendNewMessage(message,
                                          groupId:groupId,
                                          messageId:messageId,
                                          imgData: docContent.data){ result in
            if result.operationFailed{
                firestoreViewModel.removeMessageFromGroup(groupId, messageId: messageId, storageId: storageId)
            }
            onResult?(result)
        }
    }
    
}

