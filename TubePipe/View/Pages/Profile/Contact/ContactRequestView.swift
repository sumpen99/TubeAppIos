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
    @State var requestHeader:RequestsAwaitingheader = .REQUEST_SENT
  
    private var requestsAwaitingheader:[RequestsAwaitingheader] = [
        .REQUEST_SENT,
        .REQUESTS_RECIEVED
    ]
    
    var requestHeaderMenuList:  some View{
        ScrollView(.horizontal){
            LazyHStack(alignment: .top, spacing: 30, pinnedViews: [.sectionHeaders]){
                ForEach(requestsAwaitingheader, id: \.self) { header in
                    requestHeaderCell(header)
               }
            }
        }
        .scrollIndicators(.never)
        .frame(height:MENU_HEIGHT)
    }
    
    var headerOnEnter:RequestsAwaitingheader{
        if(firestoreViewModel.pendingContacts.keys.count > 0){ return .REQUEST_SENT }
        else{
            return firestoreViewModel.recievedContacts.keys.count > 0 ? .REQUESTS_RECIEVED : .REQUEST_SENT
        }
    }
    
    func requestHeaderCell(_ request:RequestsAwaitingheader) -> some View{
        return Text(request.rawValue)
        .font(.headline)
        .bold()
        .frame(height: 33)
        .foregroundColor(request == requestHeader ? .white : Color.darkGray )
        .background(
             ZStack{
                 if request == requestHeader{
                     Color.systemBlue
                     .frame(height: 1)
                     .offset(y: 14)
                     .matchedGeometryEffect(id: "CURRENTREQUESTHEADER", in: animation)
                 }
             }
        )
        .onTapGesture {
            withAnimation{
                requestHeader = request
            }
        }
    }
    
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
             }
        }
    }
    
    @ViewBuilder
    func getCurrentPage(_ header:RequestsAwaitingheader) -> some View{
        switch header{
        case .REQUEST_SENT:          pendingContactRequestSection
        case .REQUESTS_RECIEVED:     recievedContactRequestSection
        }
    }
    
    var mainpage:some View{
        VStack(spacing:10){
            requestHeaderMenuList
            getCurrentPage(requestHeader)
        }
        .padding()
    }
    
    var body: some View{
        AppBackgroundStack(content: {
            mainpage
        })
        .onAppear{
            requestHeader = headerOnEnter
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                BackButton(title: "Contacts")
                .toolbarFontAndPadding()
            }
         }
        .navigationBarBackButtonHidden()
        .alert(isPresented: $cVar.isSelectedContact, content: {
                    onAlertWithOkAction(actionPrimary: {
                        switch cVar.alertAction{
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
                fireAcceptRequestAction()
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
            firestoreViewModel.removeContactRequestFrom(currentContact){ result in
                if !result.hasCriticalError{
                    firestoreViewModel.createMessageGroupDocument(newMessageGroup,groupId:groupId){ result in}
                }
                // else show some info
            }
        }
        cVar.currentContact = nil
    }
}
