//
//  InboxContactMessages.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-08-28.
//

import SwiftUI

struct InboxContactMessages:View{
    @State var cVar = ContactVar()
        
    var contactList:some View{
        SortedContactsList(currentContact:$cVar.currentContact,
                           showingOptions: $cVar.showingOptions,
                           contactCardOption: .CONTACT_CARD_MESSAGES_ONLY,
                           contactSectionOption: .WITHOUT_SECTION_MESSAGES_ONLY,
                           contactAvatarColor: Color.systemGray,
                           contactInfoColor: .black)
    }
    
    var mainPage:some View{
        contactList
    }
    
    var body: some View{
        AppBackgroundStack(content: {
            mainPage
        })
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                BackButton(title: "Profile")
            }
       }
        .navigationBarBackButtonHidden()
        .modifier(NavigationViewModifier(title: ""))
    }
}
