//
//  SearchContactsView.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-08-10.
//

import SwiftUI

struct SearchVar{
    var searchText:String = ""
    var showingOptions:Bool = false
    var isRequestSent:Bool = false
    var currentContact:Contact?
    
    mutating func clearSearch(){
        searchText = ""
        currentContact = nil
    }
}

struct SearchContactsView: View{
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var firestoreViewModel: FirestoreViewModel
    @FocusState var focusField: Field?
    @State var sVar:SearchVar = SearchVar()
    
    func contactAvatar(c:String) -> some View{
        Text("\(c)").avatar(initial: c)
    }
    
    func contactRow(contact:Contact) -> some View{
        return VStack{
            Text(contact.displayName ?? "").lineLimit(1).font(.subheadline).hLeading().bold()
            Text(contact.email ?? "").lineLimit(1).font(.subheadline).hLeading()
        }
    }
    
    @ViewBuilder
    func contactConfirmationDialogButton(contact:Contact) ->  some View{
        switch contact.status{
        case .NO_REQUEST:
            Button(action: {
                sVar.currentContact = contact
                sVar.showingOptions.toggle()
            }, label: {
                Text("\(Image(systemName: "person.badge.plus"))").font(.title)
            })
        default:
            Text(contact.status?.searchResultLabel() ?? "").font(.caption).lineLimit(1)
        }
    }
    
    func contactCard(_ contact:Contact) -> some View{
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
    
    var searchField:some View{
        HStack(spacing:H_SPACING_REG){
            Image(systemName: "magnifyingglass").padding(.leading,2)
            TextField("",text:$sVar.searchText.max(MAX_TEXTFIELD_LEN))
                .preferedSearchField()
                .placeholder("find user",
                             when: (focusField != .FIND_USER) && (sVar.searchText.isEmpty))
                .focused($focusField,equals: .FIND_USER)
                .hLeading()
                .onSubmit {
                    firestoreViewModel.releaseContactSuggestions()
                    firestoreViewModel.queryUsers(sVar.searchText)
                }
            Spacer()
            Button("Cancel",action:closeView)
            .padding(.trailing)
            .foregroundColor(Color.systemBlue)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 5)
                .stroke(lineWidth: 1)
        )
        .foregroundColor(.black)
        .padding()
    }
    
    var searchResult:some View{
        ScrollView{
            LazyVStack(){
                ForEach(firestoreViewModel.contactSuggestions,id:\.self){ contact in
                    contactCard(contact)
                }
            }
        }
    }
    
    var buttonsSendRequest:some View{
        VStack{
            Button("Send request") {
                sendContactRequest()
            }
            Button("Cancel", role: .cancel){}
        }
        
    }
    
    var body:some View{
        VStack{
            searchField
            searchResult
        }
        .modifier(HalfSheetModifier())
        .confirmationDialog(sVar.currentContact?.displayName ?? "",
                            isPresented: $sVar.showingOptions,
                            titleVisibility: .visible){
             buttonsSendRequest
        } message: {
            Text(sVar.currentContact?.email ?? "")
        }
        .alert(isPresented: $sVar.isRequestSent, content: {
            onResultAlert()
        })
        .onTapGesture{ endTextEditing() }
        .onAppear{
            firestoreViewModel.releaseContactSuggestions()
            focusField = .FIND_USER
        }
    }
    
    //MARK: HELPER METHODS
    func closeView(){
        dismiss()
    }
    
    func sendContactRequest(){
        guard var contact = sVar.currentContact else { return }
        contact.setNewGroupId()
        firestoreViewModel.sendContactRequestTo(contact){ result in
            if result.hasCriticalError{ firestoreViewModel.removeContactRequestTo(contact)}
            fireSentRequestAlert(isSuccess: result.isSuccess,message:result.message,displayInfo: contact.displayInfo)
        }
    }
    
    func fireSentRequestAlert(isSuccess:Bool,message:String,displayInfo:String){
        firestoreViewModel.releaseContactSuggestions()
        if isSuccess{
            ALERT_TITLE = "Attention"
            ALERT_MESSAGE = message
        }
        else{
            ALERT_TITLE = "Request sent"
            ALERT_MESSAGE = "\(message) to \(displayInfo)"
        }
        sVar.isRequestSent.toggle()
        sVar.clearSearch()
    }
    
}
