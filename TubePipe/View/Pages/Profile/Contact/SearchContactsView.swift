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
    
    var searchLabel:some View{
        Image("Search")
        .resizable()
        .vCenter()
        .hCenter()
    }
    
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
                Text("\(Image(systemName: "person.badge.plus"))").font(.title).foregroundColor(.systemBlue)
            })
        default:
            Text(contact.status?.searchResultLabel() ?? "")
                .font(.caption)
                .italic()
                .lineLimit(1)
                .foregroundColor(.tertiaryLabel)
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
        .background{
            Color.white.opacity(0.7)
        }
   }
    
    var searchField:some View{
        HStack(spacing:H_SPACING_REG){
            Image(systemName: "magnifyingglass").padding(.leading,2)
            TextField("",text:$sVar.searchText.max(MAX_TEXTFIELD_LEN))
                .preferedSearchField()
                .focused($focusField,equals: .FIND_USER)
                .placeholder("ex. email or username",
                             when: (focusField != .FIND_USER) && (sVar.searchText.isEmpty))
                .hLeading()
                .onSubmit { startSearch() }
                .submitLabel(.search)
            if !firestoreViewModel.contactSuggestions.isEmpty{
                Button("Clear",action: clearSearchSuggestions)
               .padding(.trailing)
               .foregroundColor(Color.systemBlue)
            }
            
        }
        .overlay(
            RoundedRectangle(cornerRadius: 5)
                .stroke(lineWidth: 1)
        )
        .foregroundColor(.black)
        .padding(.horizontal)
    }
    
     var searchResult:some View{
         ZStack{
            searchLabel
            ScrollView{
                LazyVStack(){
                    ForEach(firestoreViewModel.contactSuggestions,id:\.self){ contact in
                        contactCard(contact)
                    }
                }
            }
        }
        .vTop()
        
    }
    
    var buttonsSendRequest:some View{
        Button("Send request") {
            sendContactRequest()
        }
        
    }
    
    var body:some View{
        VStack(spacing:0){
            TopMenu(title: "Search for friends", actionCloseButton: closeView)
            searchField
            searchResult
        }
        .onDisappear{
            clearSearchSuggestions()
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
        
    }
    
    //MARK: HELPER METHODS
    func closeView(){
        dismiss()
    }
    
    func clearSearchSuggestions(){
        sVar.searchText = ""
        firestoreViewModel.releaseData([.DATA_CONTACT_SUGGESTION])
    }
    
    func startSearch(){
        let txt = sVar.searchText.trimmingCharacters(in: .whitespaces)
        if txt.isEmpty{ return }
        firestoreViewModel.releaseData([.DATA_CONTACT_SUGGESTION])
        firestoreViewModel.queryUsers(txt)
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
        clearSearchSuggestions()
        if !isSuccess{
             ALERT_TITLE = "Attention"
            ALERT_MESSAGE = message
            sVar.isRequestSent.toggle()
        }
    }
    
}
