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
        
    var contactList:some View{
        SortedContactsList(currentContact:$cVar.currentContact,
                           showingOptions: $cVar.showingOptions,
                           contactCardOption: .CONTACT_CARD_MESSAGES_ONLY,
                           contactSectionOption: .INBOX_CONTACT_MESSAGES_VIEW_SECTION,
                           contactAvatarColor: .black,
                           contactInfoColor: .black)
    }
   
    var body: some View{
        AppBackgroundStack(content: {
            contactList
        })
        .hiddenBackButtonWithCustomTitle("Profile")
        .modifier(NavigationViewModifier(title: ""))
    }
    
}
