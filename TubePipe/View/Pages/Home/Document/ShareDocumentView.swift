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
    @State var docContent:DocumentContent = DocumentContent()
    @State var sclVar: SortedContactListVar = SortedContactListVar()
    @State var isSendResult:Bool = false
    
    var buttonIsDisabled:Bool{
        sclVar.currentContact == nil
    }
    
    var shareButton: some View{
        HStack{
            Button(action: startSendingMessageProcess,label: {
                Text("Send").hCenter()
            })
            .disabled(buttonIsDisabled)
            .buttonStyle(ButtonStyleDisabledable(lblColor:Color.black))
        }
        .padding()
    }
    
    var suggestionsList: some View{
        SortedContactsList(currentContact:$sclVar.currentContact,
                           showingOptions: $sclVar.showingOptions,
                           contactCardOption: .CONTACT_CARD_TAP_ON_CARD,
                           contactSectionOption: .WITHOUT_SECTION,
                           contactAvatarColor: .black,
                           contactInfoColor: .black)
        .frame(maxWidth: .infinity,
               minHeight: 0,
               maxHeight: 100 * CGFloat(min(3,firestoreViewModel.confirmedContacts.count)))
    }
    
    var reciever: some View{
        VStack(spacing: 5.0){
            HStack{
                Label("Send to: ",systemImage: "person.crop.square").foregroundColor(Color.systemGray)
                if sclVar.currentContact != nil{
                    Text(sclVar.currentContact?.displayName ?? "")
                }
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
        .halfSheetWhitePadding()
    }
    
    var mainContent:some View{
        VStack(spacing:10){
            ScrollView{
                VStack(spacing:20){
                    reciever
                    BaseTubeTextField(docContent: $docContent)
                    ImagePickerSwiftUi(docContent: $docContent)
                }
            }
            shareButton
        }
        .padding([.leading,.trailing])
    }
    
    var body: some View{
        VStack{
            TopMenu(title: "Share document", actionCloseButton: closeView)
            Section(header: Text(Date().formattedString()).sectionTextSecondary(color:.tertiaryLabel).padding(.leading)){
                mainContent
            }
            
        }
        .alert(isPresented: $isSendResult, content: { onResultAlert(action: closeView) })
        .onChange(of: sclVar.showingOptions){ value in
           withAnimation{
               sclVar.isSuggestionShowing.toggle()
            }
            
        }
        .onTapGesture{ endTextEditing() }
        .halfSheetBackgroundStyle()
   
    }
    
    //MARK: - BUTTON FUNCTIONS
    func closeView(){
        dismiss()
    }
    
    func startSendingMessageProcess(){
        guard let contact = sclVar.currentContact,
              let senderId = firestoreViewModel.currentUserID,
              let groupId = firestoreViewModel.getGroupIdFromOtherUserId(contact.userId)
        else { showSendMessageAlert(FirebaseError.FAILED_TO_SEND_MESSAGE.localizedDescription);return}
        
        let messageId = UUID().uuidString
        let storageId:String? = (docContent.data == nil) ? nil : UUID().uuidString
        
        //dialogPresentation.show(content: .autofillProgressView())
        sendMessage(groupId:groupId,
                    senderId:senderId,
                    messageId: messageId,
                    storageId: storageId){ result in
            if result.operationHasMessage{
                showSendMessageAlert(result.message)
            }
            else{
                closeView()
            }
            //dialogPresentation.presentedText = err?.localizedDescription ?? "Message sent!"
            //dialogPresentation.closeWithAnimationAfter(time: 2.5)
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
    
    func showSendMessageAlert(_ message:String){
        ALERT_TITLE = "Attention!"
        ALERT_MESSAGE = "\(message)"
        isSendResult.toggle()
    }
    
}
