//
//  ContactCard.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-08-28.
//

import SwiftUI

enum AlertAction{
    case SEND_REQUEST
    case ACCEPT_REQUEST
    case REJECT_REQUEST_SENT_TO_ME
    case REMOVE_CONNECTED_FRIEND
    case REMOVE_REQUEST_SENT_FROM_ME
}

struct ContactVar{
    var isSelectedContact:Bool = false
    var isSearchOption:Bool = false
    var showingOptions:Bool = false
    var currentContact:Contact?
    var alertAction:AlertAction?
}

struct ContactCard:View{
    let contact:Contact
    @Binding var cVar:ContactVar
    
    func contactAvatar(c:String) -> some View{
        Text("\(c)").avatar(initial: c)
    }
    
    func contactRow(contact:Contact) -> some View{
        return VStack{
            Text(contact.displayName ?? "").lineLimit(1).font(.subheadline).hLeading().bold()
            Text(contact.email ?? "").lineLimit(1).font(.subheadline).hLeading()
        }
    }
    
    func contactConfirmationDialogButton(contact:Contact) ->  some View{
        Button(action: {
            cVar.currentContact = contact
            cVar.showingOptions.toggle()
        }, label: {
            Text("\(Image(systemName: "ellipsis"))").font(.headline)
        })
    }
    
    var body: some View{
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
   }
}
