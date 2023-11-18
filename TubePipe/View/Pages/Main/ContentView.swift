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
    
    init(){
        UIView.changeUIAlertTintColor()
        UITabBar.changeAppearance()
        UINavigationBar.changeAppearance()
    }
    
    var body: some View {
        ZStack{
             switch firebaseAuth.loggedInAs{
                case .NOT_LOGGED_IN:    WelcomeView()
                case .ANONYMOUS_USER:   MainView()
                case .REGISTERED_USER:  MainView()
                case .ADMIN_USER:       MainView()
                default:                WelcomeView()
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
    
    func releaseData(){
        firestoreViewModel.releaseData(FirestoreData.all())
        firestoreViewModel.closeListeners(FirestoreListener.all())
    }
    
    func setUserDataIfNeededData(){
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
