//
//  ContactRequestView.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-08-28.
//

import SwiftUI

enum RequestsAwaitingheader:String,CaseIterable{
    case REQUEST_SENT = "Sent requests"
    case REQUESTS_RECIEVED = "Recieved requests"
}

struct ContactRequestView:View{
    @Namespace var animation
    @EnvironmentObject var firestoreViewModel: FirestoreViewModel
    @State var cVar = ContactVar()
  
    private var requestsAwaitingheader:[RequestsAwaitingheader] = [
        .REQUEST_SENT,
        .REQUESTS_RECIEVED
    ]
    
    @ViewBuilder
    func contactDescription(_ contact:Contact?) -> some View{
        if let contact = contact{
            VStack{
                ContactCard(contact:contact,cVar: $cVar)
                Divider()
            }
        }
    }
    
    var recievedContactRequestSection:some View{
        ScrollView{
            LazyVStack(){
                if firestoreViewModel.recievedContacts.keys.count > 0{
                    ForEach(firestoreViewModel.recievedContacts.keys,id:\.self){ key in
                        let contact = firestoreViewModel.recievedContacts[key]
                        contactDescription(contact)
                    }
                }
                else{
                    Text("No requests awaiting")
                    .noDataBackground()
                }
            }
        }
    }
    
    var pendingContactRequestSection:some View{
        ScrollView{
            LazyVStack(){
                if firestoreViewModel.pendingContacts.keys.count > 0{
                    ForEach(firestoreViewModel.pendingContacts.keys,id:\.self){ key in
                        let contact = firestoreViewModel.pendingContacts[key]
                        contactDescription(contact)
                    }
                }
                else{
                    Text("No requests sent")
                    .noDataBackground()
                }
            }
        }
    }
    
    var awaitingContactRequestsSection:some View{
        ScrollView{
            LazyVStack(){
                ForEach(requestsAwaitingheader,id:\.self){ header in
                    Section {
                        if header == .REQUEST_SENT { pendingContactRequestSection}
                        else{ recievedContactRequestSection}
                    } header: {
                        Text("\(header.rawValue):")
                        .sectionText(color:.systemGray)
                        .padding(.leading)
                    }
                    Divider()
                }
            }
        }
    }
    
   
    
    var mainpage:some View{
        awaitingContactRequestsSection
        .padding()
    }
    
    var body: some View{
        NavigationView{
            AppBackgroundStack(content: {
                mainpage
            })
            .modifier(NavigationViewModifier(title: ""))
        }
        .sheet(isPresented: $cVar.isSearchOption){
            SearchContactsView()
            .presentationDragIndicator(.visible)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                BackButton(title: "Contacts")
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    withAnimation{
                        cVar.isSearchOption.toggle()
                    }}){
                        Label("Search", systemImage: "magnifyingglass")
                    }
            }
        }
        .navigationBarBackButtonHidden()
        .alert(isPresented: $cVar.isSelectedContact, content: {
                    onAlertWithOkAction(actionPrimary: {
                        switch cVar.alertAction{
                        case .ACCEPT_REQUEST: fireAcceptRequestAction()
                        case .REJECT_REQUEST_SENT_TO_ME: fireRejectRequestSentToMeAction()
                        case .REMOVE_REQUEST_SENT_FROM_ME: fireRemoveRequestSentFromMeAction()
                        default:break
                        }
                    })
        })
        .confirmationDialog(cVar.currentContact?.displayName ?? "",
                            isPresented: $cVar.showingOptions,
                            titleVisibility: .visible){
                switch cVar.currentContact?.status{
                case .PENDING_REQUEST: buttonsPending
                case .RECIEVED_REQUEST: buttonsRecieved
                default: buttonsDefault
            }
        } message: {
            Text(cVar.currentContact?.email ?? "")
        }
    }

    var buttonsPending:some View{
        VStack{
            Button("Remove request",role: .destructive) {
                removeRequestSentFromMeAlert()
            }
            Button("Cancel", role: .cancel){}
        }
        
    }
    
    var buttonsRecieved:some View{
        VStack{
            Button("Accept request") {
                acceptRequesSentToMe()
            }
            Button("Remove request",role: .destructive) {
                rejectRequestSentToMeAlert()
            }
            Button("Cancel", role: .cancel){}
        }
        
    }
    
    var buttonsDefault:some View{
        Button("Cancel", role: .cancel){}
    }
    
    //MARK: - BUTTON FUNCTIONS
    func removeRequestSentFromMeAlert(){
        guard let contact = cVar.currentContact else { return }
        ALERT_TITLE = "Remove request"
        ALERT_MESSAGE = "Do you want to remove request sent to \(contact.displayInfo)"
        cVar.alertAction = .REMOVE_REQUEST_SENT_FROM_ME
        cVar.isSelectedContact.toggle()
    }
    
    func rejectRequestSentToMeAlert(){
        guard let contact = cVar.currentContact else { return }
        ALERT_TITLE = "Remove request"
        ALERT_MESSAGE = "Do you want to remove request from \(contact.displayInfo)"
        cVar.alertAction = .REJECT_REQUEST_SENT_TO_ME
        cVar.isSelectedContact.toggle()
    }
        
    func acceptRequesSentToMe(){
        guard let contact = cVar.currentContact else { return }
        ALERT_TITLE = "Accept request"
        ALERT_MESSAGE = "Do you want to add \(contact.displayInfo) to contacts?"
        cVar.alertAction = .ACCEPT_REQUEST
        cVar.isSelectedContact.toggle()
    }
    
    func fireRemoveRequestSentFromMeAction(){
        guard let contact = cVar.currentContact else { return }
        firestoreViewModel.removeContactRequestTo(contact){ result in }
        cVar.currentContact = nil
    }
    
    func fireRejectRequestSentToMeAction(){
        guard let contact = cVar.currentContact else { return }
        firestoreViewModel.removeContactRequestFrom(contact){ result in}
        cVar.currentContact = nil
    }
    
    func fireAcceptRequestAction(){
        guard let currentContact = cVar.currentContact,
              let groupId = currentContact.groupId,
              let otherUserId = currentContact.userId,
              let newMessageGroup = firestoreViewModel.createNewMessageGroup(groupId: groupId, otherUserId: otherUserId)
        else { return }
        firestoreViewModel.acceptContactRequestFrom(currentContact){ result in
            if result.hasCriticalError{ firestoreViewModel.removeContactRequestFrom(currentContact)}
            else{ firestoreViewModel.createMessageGroupDocument(newMessageGroup,groupId:groupId){ result in
                // show result
            }}
       }
       cVar.currentContact = nil
    }
}
