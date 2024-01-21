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
    @EnvironmentObject var tubeViewModel: TubeViewModel
    @FocusState var focusField: Field?
    @State var docContent:DocumentContent = DocumentContent()
    @State var sclVar: SortedContactListVar = SortedContactListVar()
    @State private var toast: Toast? = nil
    @State var invalidTube:Bool = false
  
    var buttonIsDisabled:Bool{
        sclVar.currentContact == nil||docContent.message.isEmpty
    }
    
    var buttonClearIsDisabled:Bool{
        docContent.message.isEmpty
    }
    
    var toogleContactsButton:some View{
        Image(systemName: "chevron.up.chevron.down" )
    }
    
    var clearButton: some View{
        Button(action:{ docContent.message = "";},label: {
            Image(systemName: "xmark.square.fill")
        })
        .foregroundStyle(buttonIsDisabled ? Color.tertiaryLabel : .red)
        .font(.title2)
        .bold()
    }
    
    var shareButton: some View{
        Button(action:startSendingMessageProcess,label: {
            Text("Send")
            .font(.title3)
            .padding(.horizontal,10)
            .padding(.vertical,3)
            .overlay(
                RoundedRectangle(cornerRadius:10.0)
                    .stroke(buttonIsDisabled ? Color.tertiaryLabel : Color.systemBlue, lineWidth: 1)
            )
            
        })
        .foregroundStyle(buttonIsDisabled ? Color.tertiaryLabel : .systemBlue)
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
    
    var contactField:some View{
        HStack{
            Label("Send to: \(sclVar.currentContact?.displayName ?? "")",systemImage: "person.crop.square").hLeading()
            Spacer()
            clearContactField
            toogleContactsButton
            
        }
        .hLeading()
        .contentShape(Rectangle())
        .onTapGesture {
            endTextEditing()
            withAnimation{ sclVar.isSuggestionShowing.toggle() }
        }
    }
    
    @ViewBuilder
    var clearContactField:some View{
        if sclVar.currentContact != nil{
            Button(action: { withAnimation{ sclVar.currentContact = nil } }){
                Image(systemName: "xmark")
                .foregroundStyle(.red)
            }
       }
    }
    
    var reciever: some View{
        VStack(spacing: 5.0){
            contactField
            Divider()
            if sclVar.isSuggestionShowing{
                suggestionsList
            }
        }
        .roundedBorder()
    }
    
    var mainContent:some View{
        VStack(spacing:20){
            reciever.padding([.leading,.trailing,.top])
            BaseTubeTextField(docContent: $docContent,
                              focusField: _focusField,
                              placeHolder:"Add a message or subject to share with friend")
            .padding()
        }
    }
    
    var body: some View{
        VStack(spacing:0){
            TopMenu(title: "Share document", actionCloseButton: closeView)
            Section {
                mainContent.vTop()
                
            } header:{
                HStack{
                    Text(Date().formattedString()).sectionTextSecondary(color:.black).hLeading().padding(.leading)
                    clearButton.padding(.trailing)
                    shareButton.padding(.trailing)
                }
            }
        }
        .alert("Tube error!", isPresented: $invalidTube){
            Button("OK", role: .cancel,action: { closeView() })
        } message: {
            Text("Current Tubevalues are invalid. We dont think there`s a friend who would like to recieve them. Sorry for any inconvenience. We`re closing this view now.")
        }
        .onAppear{
            if !closeIfInvalidTube(){
                firestoreViewModel.initializeListenerContactRequests([.LISTENER_CONTACT_REQUESTS_CONFIRMED])
            }
        }
        .onDisappear(){
            firestoreViewModel.closeListener(.LISTENER_CONTACT_REQUESTS_CONFIRMED)
            firestoreViewModel.releaseData([.DATA_CONTACT_REQUEST])
        }
        .toastView(toast: $toast)
        .onChange(of: sclVar.showingOptions){ value in
           withAnimation{ sclVar.isSuggestionShowing.toggle() }
        }
        .halfSheetBackgroundStyle()
        .onTapGesture {
            focusField = nil
        }
    }
    
    //MARK: - BUTTON FUNCTIONS
     func closeView(){
        dismiss()
    }
    
    func closeIfInvalidTube() -> Bool{
        if tubeViewModel.muff.emptyL1OrL2{
            invalidTube.toggle()
            return true
        }
        return false
    }
    
    func startSendingMessageProcess(){
        docContent.trim()
        if buttonIsDisabled||docContent.isSaving{ return }
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

