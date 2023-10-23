//
//  ContactMessagesView.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-08-31.
//

import SwiftUI

struct CmVar{
    var currentMessage:Message?
}

struct ContactMessagesView:View{
    @EnvironmentObject var firestoreViewModel: FirestoreViewModel
    @State var cmVar:CmVar = CmVar()
    let contact:Contact
    let backButtonLabel:String
    
    var leftAttachment:some View{
        Image(systemName: "paperclip").font(.title3)
        .hLeading()
        .foregroundColor(Color.lightText)
    }
    
    var rightAttachment:some View{
        Image(systemName: "paperclip").font(.title3)
        .hTrailing()
        .foregroundColor(Color.lightText)
    }
    
    func messageDate(_ date:String) -> some View{
        Text(date)
        .foregroundColor(.white)
        .hCenter()
    }
    
    func messageBody(_ message:String, _ direction:BubbleDirection) -> some View{
        ZStack{
            Text(message).font(.callout)
        }
        .foregroundColor(direction == .left ? .black : .white)
        .padding()
    }
   
    @ViewBuilder
    func messsageAttachment(_ direction:BubbleDirection) -> some View{
        ZStack{
            switch direction{
            case .left:  leftAttachment
            case .right: rightAttachment
            }
        }
    }
    
    func messageRecieved(_ message:String) -> some View{
        messageBody(message,.left)
        .background(Color.lightText)
    }
    
    func messageSent(_ message:String) -> some View{
        messageBody(message,.right)
        .background(Color.systemBlue)
    }
    
    @ViewBuilder
    func messageBubble(_ message:Message,date:Date,direction:BubbleDirection) -> some View{
        if let messageBody = message.message{
            VStack(spacing:V_SPACING_REG){
                messageDate(date.iosLongMessageFormat())
                ChatBubble(direction: direction) {
                    switch direction{
                    case .left: messageRecieved(messageBody)
                    case .right: messageSent(messageBody)
                    }
                }
                messsageAttachment(direction)
                .onTapGesture {
                    cmVar.currentMessage = message
                }
            }
            .padding()
        }
    }
    
    @ViewBuilder
    func messageCard(_ message:Message) -> some View{
        if let from = message.senderId,
           let currentUserID = firestoreViewModel.currentUserID,
           let date = message.date{
           messageBubble(message,date:date,direction: from == currentUserID ? .right : .left)
        }
    }
    
    var mainPage:some View{
        ScrollViewReader { proxy in
            ScrollViewWithOffset() {
                LazyVStack{
                    ForEach(firestoreViewModel.contactMessages,id:\.messageId) { message in
                        messageCard(message)
                        .id(message.messageId)
                    }
                    .onAppear{
                        if let itemIdAtBottom = firestoreViewModel.contactMessages.last?.messageId{
                            proxy.scrollTo(itemIdAtBottom)
                        }
                    }
                }
                .padding()
            }
       }
    }
    
    var mainPage2:some View{
        ScrollView{
            LazyVStack{
                ForEach(firestoreViewModel.contactMessages,id:\.self){ message in
                    messageCard(message)
                }
            }
        }
    }
    
    var body: some View{
        AppBackgroundStack(content: {
            mainPage
        })
        .sheet(item: $cmVar.currentMessage){ message in
            AttachmentView(message: message,userName:contact.displayName ?? "Back")
            .presentationDragIndicator(.visible)
        }
        .onAppear{
            firestoreViewModel.loadThreadDocumentsFromContact(contact.groupId)
        }
        .onDisappear{
            firestoreViewModel.releaseContactMessages()
        }
        .hiddenBackButtonWithCustomTitle(backButtonLabel)
    }
    
}
