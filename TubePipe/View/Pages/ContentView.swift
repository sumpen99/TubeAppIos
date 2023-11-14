//
//  ContentView.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-06-10.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var firebaseAuth:FirebaseAuth
    @EnvironmentObject var firestoreViewModel:FirestoreViewModel
    @EnvironmentObject var navigationViewModel:NavigationViewModel
    @StateObject var tubeViewModel = TubeViewModel()
    
    init(){
        UIView.changeUIAlertTintColor()
        UITabBar.changeAppearance()
        UINavigationBar.changeAppearance()
    }
    
    var body: some View {
        NavigationStack(path:$navigationViewModel.pathTo){
            ZStack{
                 switch firebaseAuth.loggedInAs{
                    case .NOT_LOGGED_IN:   WelcomeView()
                    case .ANONYMOUS_USER:  MainView()
                    case .REGISTERED_USER: MainView()
                    case .ADMIN_USER:      MainView()
                    default:               EmptyView()
                        
                }
            }
            .navigationDestination(for: Contact.self){  contact in
                ContactMessagesView(contact: contact,backButtonLabel: "Messages")
            }
            .navigationDestination(for: ProfileRoute.self){  route in
                switch route{
                case .ROUTE_SETTINGS_TUBE:  UserSettingsView()
                case .ROUTE_MESSAGES:       InboxContactMessages()
                case .ROUTE_CONTACTS:       ContactView()
                case .ROUTE_FEATURE:        FeatureView()
                case .ROUTE_ISSUE:          IssueView()
                default:                    EmptyView()
                }
            }
            .onChange(of: firebaseAuth.loggedInAs){ role in
                switch role{
                case .NOT_LOGGED_IN:       releaseData()
                case .REGISTERED_USER:     setUserDataIfNeededData()
                default: break
                }
            }
        }
        .environmentObject(tubeViewModel)
         
    }
    
    func releaseData(){
        firestoreViewModel.releaseData(FirestoreData.all())
        firestoreViewModel.closeListeners(FirestoreListener.all())
    }
    
    func setUserDataIfNeededData(){
        tubeViewModel.delayedInit()
        firestoreViewModel.checkIfUserDocumentExists(){ error,documentExists in
            if documentExists{ setupListenerForUserChanges() }
            else { setUpNewUser()}
        }
    }
    
    func setUpNewUser(){
        firestoreViewModel.createAppUserDocument(){ error in
            if error == nil { setupListenerForUserChanges() }
        }
        
    }
    
    func setupListenerForUserChanges(){
        firestoreViewModel.listenForCurrentUser()
        firestoreViewModel.listenForMessageGroups()
    }
}
