//
//  ContactView.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-07-24.
//

import SwiftUI

enum ActiveContactSheet: Identifiable {
    case OPEN_SEARCH
    case OPEN_CONTACT_REQUESTS
     
    var id: Int {
        hashValue
    }
}

struct ContactView:View{
    @Namespace var animation
    @EnvironmentObject var firestoreViewModel: FirestoreViewModel
    @State var activeContactSheet: ActiveContactSheet?
    @State var cVar = ContactVar()
    @State var isMoveToMessages:Bool = false
    
    var showNoContactsLabel:Bool{
        return possibleBadgeCount <= 0 && firestoreViewModel.confirmedContacts.isEmpty
    }
    
    var possibleBadgeCount:Int{
        firestoreViewModel.possibleBadgeCount
    }
    
    var contactsLabel:some View{
        Image("Contacts")
        .resizable()
        .vCenter()
        .hCenter()
    }
    
    @ViewBuilder
    var confirmedContactRequestSection:some View{
        SortedContactsList(currentContact:$cVar.currentContact,
                           showingOptions: $cVar.showingOptions,
                           contactCardOption: .CONTACT_CARD_ELLIPSE,
                           contactSectionOption: .CONTACT_VIEW_SECTION,
                           contactAvatarColor:.black,
                           contactInfoColor: Color.black)
    }
    
    var badgedContactRequestButton:some View{
        NavigationLink(destination:LazyDestination(destination: {
            ContactRequestView()
            
        })){
            Image(systemName: "person.badge.plus")
        }
        .badge(value: "\(possibleBadgeCount)")
    }
    
    @ViewBuilder
    var mainpage:some View{
        ZStack{
            contactsLabel
            confirmedContactRequestSection.padding(.top)
        }
    }
    
    var body: some View{
        AppBackgroundStack(content: {
            mainpage
        },title: "Contacts")
        .hiddenBackButtonWithCustomTitle("Profile")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { activeContactSheet = .OPEN_SEARCH }){
                    Label("Search", systemImage: "magnifyingglass")
                    .toolbarFontAndPadding()
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                if possibleBadgeCount > 0 {
                    Button(action: { activeContactSheet = .OPEN_CONTACT_REQUESTS }){
                        Image(systemName: "person.badge.plus")
                        .badge(value: "\(possibleBadgeCount)")
                        .toolbarFontAndPadding(.title3)
                    }
                 }
            }
        }
        .onChange(of: activeContactSheet){ item in
            if let item{
                activeContactSheet = nil
                switch item{
                case .OPEN_SEARCH:
                    SheetPresentView(style: .sheet){
                        SearchContactsView()
                        .environmentObject(firestoreViewModel)
                    }
                    .makeUIView()
                case .OPEN_CONTACT_REQUESTS:
                    SheetPresentView(style: .sheet){
                        ContactRequestView()
                        .environmentObject(firestoreViewModel)
                    }
                    .makeUIView()
                }
            }
        }
        .alert(isPresented: $cVar.isSelectedContact, content: {
            onAlertWithOkAction(actionPrimary: {
                switch cVar.alertAction{
                case .REMOVE_CONNECTED_FRIEND: fireRemoveConnectedFriendAction()
                default:break
                }
            })
        })
        .confirmationDialog(cVar.currentContact?.displayName ?? "",
                            isPresented: $cVar.showingOptions,
                            titleVisibility: .visible){
                switch cVar.currentContact?.status{
                case .CONFIRMED_REQUEST: buttonsConfirmed
                default: buttonsDefault
            }
        } message: {
            Text(cVar.currentContact?.email ?? "")
        }
    }

    var buttonsConfirmed:some View{
        VStack{
            Button("Remove contact",role: .destructive) {
                removeContactFriendAlert()
            }
            Button("Cancel", role: .cancel){}
        }
        
    }
    
    var buttonsDefault:some View{
        Button("Cancel", role: .cancel){}
    }
    
    //MARK: - BUTTON FUNCTIONS
    func removeContactFriendAlert(){
        guard let contact = cVar.currentContact else { return }
        ALERT_TITLE = "Remove contact"
        ALERT_MESSAGE = "Do you want to remove \(contact.displayInfo)?"
        cVar.alertAction = .REMOVE_CONNECTED_FRIEND
        cVar.isSelectedContact.toggle()
    }
    
    func fireRemoveConnectedFriendAction(){
        guard let contact = cVar.currentContact else { return }
        firestoreViewModel.removeConnectionTo(contact){ result in }
        cVar.currentContact = nil
    }
    
}
