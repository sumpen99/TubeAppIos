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
    case WITH_SECTION
    case WITHOUT_SECTION
    case WITHOUT_SECTION_MESSAGES_ONLY
}

struct SortedContactsList: View{
    @EnvironmentObject var firestoreViewModel: FirestoreViewModel
    @Binding var currentContact:Contact?
    @Binding var showingOptions:Bool
    let contactCardOption:ContactCardOption
    let contactSectionOption:ContactSectionOption
    let contactAvatarColor:Color
    let contactInfoColor:Color
    var navigateToContact:((Contact) -> Void)?
    
    var personAvatar: some View{
        Image(systemName: "person.circle.fill")
            .resizable()
            .frame(width: 40,height: 40)
            .foregroundColor(contactAvatarColor)
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
        .foregroundColor(contactInfoColor)
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
                .lineLimit(2)
                .foregroundColor(contactInfoColor)
                .font(.caption)
                .hLeading()
        }
        .vTop()
        .foregroundColor(contactInfoColor)
    }
    
    func navigationChevron(contact:Contact) -> some View{
        HStack{
            if let date = firestoreViewModel.getLatestMessageDetail(contact.groupId,messageDetail: .MESSAGE_DATE) as? Date{
                Text(date.iosShortMessageFormat())
                    .font(.callout)
                    .foregroundColor(Color.systemGray)
            }
            Image(systemName: "chevron.right")
            .foregroundColor(Color.systemGray)
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
    // CONTACTIVIEW
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
        
    }
    // SHAREDOCUMENT
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
    // INBOXCONTACTMESSAGES
    func contactCardMessagesOnly(_ contact:Contact) -> some View{
        NavigationLink(destination:LazyDestination(destination: {
            ContactMessagesView(contact: contact,backButtonLabel: "Messages") })) {
                HStack{
                    personAvatar
                    contactRowMessage(contact: contact)
                    navigationChevron(contact: contact)
                }
                .padding()
                .hLeading()
        }
        .buttonStyle(ButtonStyleNavigationLink())
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
    // CONTACTIVIEW
    func contactSection(_ initial:String) -> some View{
        Section {
            LazyVStack{
                ForEach(firestoreViewModel.confirmedContacts[initial] ?? [],id:\.self){ contact in
                    contactDescription(contact)
                }
            }
        } header: {
            Text(initial).sectionText(font: .largeTitle,color: Color.systemGray).padding(.leading)
        }
    }
    // SHAREDOCUMENT
    func contactNoSection(_ initial:String) -> some View{
        ForEach(firestoreViewModel.confirmedContacts[initial] ?? [],id:\.self){ contact in
            contactDescription(contact)
        }
    }
    // INBOXCONTACTMESSAGES
    func contactNoSectionMessagesOnly(_ initial:String) -> some View{
        ForEach(firestoreViewModel.confirmedContacts[initial] ?? [],id:\.self){ contact in
            if firestoreViewModel.contactInMessageGroup(contact.groupId){
                contactDescription(contact)
            }
        }
    }
    // CONTACTIVIEW
    var withContactSection: some View{
        ScrollView{
            LazyVStack{
                ForEach(firestoreViewModel.confirmedContacts.keys.sorted(by: <),id:\.self){ initial in
                    contactSection(initial)
                }
                
            }
        }
        
    }
    // SHAREDOCUMENT
    var withOutContactSection: some View{
        ScrollView{
            LazyVStack{
                ForEach(firestoreViewModel.confirmedContacts.keys.sorted(by: <),id:\.self){ initial in
                    contactNoSection(initial)
                }
            }
        }
    }
    // INBOXCONTACTMESSAGES
    var withOutContactSectionMessagesOnly: some View{
        ScrollView{
            LazyVStack{
                ForEach(firestoreViewModel.confirmedContacts.keys.sorted(by: <),id:\.self){ initial in
                    contactNoSectionMessagesOnly(initial)
                }
            }
        }
    }
    
    var body:some View{
        switch contactSectionOption {
        case .WITH_SECTION:                 withContactSection
        case .WITHOUT_SECTION:              withOutContactSection
        case .WITHOUT_SECTION_MESSAGES_ONLY: withOutContactSectionMessagesOnly
        }
        
    }
}

