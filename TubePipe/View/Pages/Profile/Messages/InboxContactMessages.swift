//
//  InboxContactMessages.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-08-28.
//

import SwiftUI

struct InboxContactMessages:View{
    @EnvironmentObject var firestoreViewModel: FirestoreViewModel
    @EnvironmentObject var navigationViewModel: NavigationViewModel
    @State var cVar = ContactVar()
    
    var messageLabel:some View{
        Text("Inbox")
        .font(.largeTitle)
        .bold()
        .foregroundColor(.black)
        .hLeading()
        .padding([.leading,.trailing])
    }
    
    var contactList:some View{
        SortedContactsList(currentContact:$cVar.currentContact,
                           showingOptions: $cVar.showingOptions,
                           contactCardOption: .CONTACT_CARD_MESSAGES_ONLY,
                           contactSectionOption: .INBOX_CONTACT_MESSAGES_VIEW_SECTION,
                           contactAvatarColor: .black,
                           contactInfoColor: .black)
    }
        
    var messagesBody:some View{
        VStack(spacing:V_SPACING_REG){
            messageLabel
            contactList
        }
    }
   
    var body: some View{
        AppBackgroundStack(content: {
            messagesBody
        },title: "Messages")
        .hiddenBackButtonWithCustomTitle("Profile")
    }
    
}
