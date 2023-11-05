//
//  ContactView.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-07-24.
//

import SwiftUI

struct ContactView:View{
    @Namespace var animation
    @EnvironmentObject var firestoreViewModel: FirestoreViewModel
    @State var cVar = ContactVar()
    @State var isMoveToMessages:Bool = false
    
    var possibleBadgeCount:Int{
        firestoreViewModel.possibleBadgeCount
    }
    
    var contactsLabel:some View{
        Text("Contacts").font(.largeTitle).bold().foregroundColor(.white).hLeading()
    }
    
    var confirmedContactRequestSection:some View{
        SortedContactsList(currentContact:$cVar.currentContact,
                           showingOptions: $cVar.showingOptions,
                           contactCardOption: .CONTACT_CARD_ELLIPSE,
                           contactSectionOption: .CONTACT_VIEW_SECTION,
                           contactAvatarColor:.black,
                           contactInfoColor: Color.GHOSTWHITE)
    }
    
    var badgedContactRequestButton:some View{
        NavigationLink(destination:LazyDestination(destination: {
            ContactRequestView()
            
        })){
            Image(systemName: "person.badge.plus")
        }
        .badge(value: "\(possibleBadgeCount)")
    }
    
    var unBadgedContactRequestButton:some View{
        NavigationLink(destination:LazyDestination(destination: {
            ContactRequestView()
            
        })){
            Image(systemName: "person.badge.plus")
        }
    }
     
    var mainpage:some View{
        VStack(spacing:V_SPACING_REG){
            contactsLabel
            confirmedContactRequestSection
        }
        .padding()
    }
    
    var body: some View{
        AppBackgroundStack(content: {
            mainpage
        })
        .hiddenBackButtonWithCustomTitle("Profile")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    withAnimation{
                        cVar.isSearchOption.toggle()
                    }}){
                        Label("Search", systemImage: "magnifyingglass")
                    }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                if possibleBadgeCount > 0 {
                    badgedContactRequestButton
                }
                else{
                    unBadgedContactRequestButton
                }
            }
        }
        .onChange(of: cVar.isSearchOption){ item in
            SheetPresentView(style: .sheet){
                SearchContactsView()
                .environmentObject(firestoreViewModel)
                .presentationDragIndicator(.visible)
            }
            .makeUIView()
        }
        /*.sheet(isPresented: $cVar.isSearchOption){
            SearchContactsView()
            .environmentObject(firestoreViewModel)
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }*/
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
