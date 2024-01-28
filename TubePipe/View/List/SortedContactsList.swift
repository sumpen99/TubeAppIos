//
//  SortedContactsList.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-08-24.
//

import SwiftUI

enum ContactCardOption{
    case CONTACT_CARD_ELLIPSE
    case CONTACT_CARD_TAP_ON_CARD
    case CONTACT_CARD_MESSAGES_ONLY
}

enum ContactSectionOption{
    case CONTACT_VIEW_SECTION
    case SHARE_DOCUMENT_VIEW_SECTION
    case INBOX_CONTACT_MESSAGES_VIEW_SECTION
}

struct SortedContactsList: View{
    @EnvironmentObject var firestoreViewModel: FirestoreViewModel
    @EnvironmentObject var navigationViewModel: NavigationViewModel
    @Binding var currentContact:Contact?
    @Binding var showingOptions:Bool
    let contactCardOption:ContactCardOption
    let contactSectionOption:ContactSectionOption
    let contactAvatarColor:Color
    let contactInfoColor:Color
    var navigateToContact:((Contact) -> Void)?
   
    var personAvatar: some View{
        Image(systemName: "face.smiling.inverse")
            .resizable()
            .frame(width: 40,height: 40)
            .foregroundStyle(contactAvatarColor)
    }
    
    func contactAvatar(c:String) -> some View{
        Text("\(c)").avatar(initial: c)
    }
    
    func contactRow(contact:Contact) -> some View{
        return VStack{
            Text(contact.displayName ?? "")
                .lineLimit(1)
                .font(.subheadline)
                .bold()
                .hLeading()
             Text(contact.email ?? "")
                .lineLimit(1)
                .font(.subheadline)
                .hLeading()
        }
        .foregroundStyle(contactInfoColor)
    }
    
    func contactRowMessage(contact:Contact) -> some View{
        return VStack{
            Text(contact.displayName ?? "")
                .lineLimit(1)
                .font(.subheadline)
                .bold()
                .hLeading()
            Text(firestoreViewModel
                .getLatestMessageDetail(contact.groupId,
                                        messageDetail: .MESSAGE_MESSAGE) as? String ?? "")
                .lineLimit(1)
                .foregroundStyle(contactInfoColor)
                .font(.caption)
                .hLeading()
        }
        .vTop()
        .foregroundStyle(contactInfoColor)
    }
    
    func navigationChevron(contact:Contact) -> some View{
        HStack{
            if let date = firestoreViewModel.getLatestMessageDetail(contact.groupId,messageDetail: .MESSAGE_DATE) as? Date{
                Text(date.iosShortMessageFormat())
                    .font(.callout)
                    .foregroundStyle(Color.systemGray)
            }
            Image(systemName: "chevron.right")
            .foregroundStyle(Color.systemGray)
        }
        .hTrailing()
        .vTop()
    }
    
    func contactConfirmationDialogButton(contact:Contact) ->  some View{
        Button(action: {
            currentContact = contact
            showingOptions.toggle()
        }, label: {
            Text("\(Image(systemName: "ellipsis"))").font(.headline)
        })
    }
  
    @ViewBuilder
    func contactDescription(_ contact:Contact?) -> some View{
        if let contact = contact{
            switch contactCardOption {
            case .CONTACT_CARD_ELLIPSE:         contactCardEllipse(contact)
            case .CONTACT_CARD_TAP_ON_CARD:     contactCardTapOnCard(contact)
            case .CONTACT_CARD_MESSAGES_ONLY:   contactCardMessagesOnly(contact)
            }
        }
    }
    
    var body:some View{
        switch contactSectionOption {
        case .CONTACT_VIEW_SECTION:                     contactViewSection
        case .SHARE_DOCUMENT_VIEW_SECTION:              shareDocumentViewSection
        case .INBOX_CONTACT_MESSAGES_VIEW_SECTION:      inboxContactMessagesViewSection
        }
    }

}

//MARK: CONTACT VIEW
extension SortedContactsList{
    
    var contactViewSection: some View{
        ScrollView{
            LazyVStack{
                ForEach(firestoreViewModel.confirmedContacts.keys.sorted(by: <),id:\.self){ initial in
                    contactSection(initial)
                }
            }
        }
    }
    
    func contactSection(_ initial:String) -> some View{
        Section {
            LazyVStack{
                ForEach(firestoreViewModel.confirmedContacts[initial] ?? [],id:\.self){ contact in
                    contactDescription(contact)
                }
            }
        } header: {
            Text(initial).sectionText(font: .title3,color: Color.systemGray).padding(.leading)
        }
    }
    
    func contactCardEllipse(_ contact:Contact) -> some View{
        VStack{
            HStack{
                let initial = contact.initial
                contactAvatar(c: initial)
                HStack{
                    contactRow(contact: contact)
                    contactConfirmationDialogButton(contact: contact)
                }
                .vCenter()
            }
            .padding()
            .hLeading()
            Divider()
        }
        .background{
            Color.white.opacity(0.7)
        }
        
    }
    
}

//MARK: SHARE DOCUMENT
extension SortedContactsList{
    
    var shareDocumentViewSection: some View{
        ScrollView{
            LazyVStack{
                ForEach(firestoreViewModel.confirmedContacts.keys.sorted(by: <),id:\.self){ initial in
                    contactNoSection(initial)
                }
            }
        }
    }
    
    func contactNoSection(_ initial:String) -> some View{
        ForEach(firestoreViewModel.confirmedContacts[initial] ?? [],id:\.self){ contact in
            contactDescription(contact)
        }
    }
    
    func contactCardTapOnCard(_ contact:Contact) -> some View{
        VStack{
            HStack{
                let initial = contact.initial
                contactAvatar(c: initial)
                contactRow(contact: contact)
                .vCenter()
            }
            .padding()
            .hLeading()
            .contentShape(Rectangle())
            .onTapGesture {
                currentContact = contact
                showingOptions.toggle()
            }
            Divider()
        }
    }
}



//MARK: INBOX CONTACT MESSAGES
extension SortedContactsList{
    
    var inboxContactMessagesViewSection: some View{
        ScrollView{
            LazyVStack{
                ForEach(firestoreViewModel.confirmedContacts.keys.sorted(by: <),id:\.self){ initial in
                    contactNoSectionMessagesOnly(initial)
                }
            }
        }
    }
    
    func contactNoSectionMessagesOnly(_ initial:String) -> some View{ 
        ForEach(firestoreViewModel.confirmedContacts[initial] ?? [],id:\.self){ contact in
            if firestoreViewModel.contactInMessageGroup(contact.groupId){
                contactDescription(contact)
            }
        }
    }
    
    func contactCardMessagesOnly(_ contact:Contact) -> some View{
        Button(action: {
            navigationViewModel.appendToPathWith(contact)
        }, label: {
            HStack{
                let initial = contact.initial
                contactAvatar(c: initial)
                contactRowMessage(contact: contact)
                navigationChevron(contact: contact)
            }
            .padding()
            .hLeading()
        })
        .buttonStyle(ButtonStyleNavigationLink())
     }
    
}

