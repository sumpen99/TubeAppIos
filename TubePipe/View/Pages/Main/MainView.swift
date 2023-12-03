//
//  MainView.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-06-10.
//

import SwiftUI

/*
 @Environment(\.scenePhase) private var phase
 .onChange(of: phase) { newPhase in
    switch newPhase {
     case .active:
         debugLog(object:newPhase)
     case .inactive:
         debugLog(object:newPhase)
         //firestoreViewModel.closeListeners(FirestoreListener.all())
         //firestoreViewModel.releaseData(FirestoreData.all())
     case .background:
         debugLog(object:newPhase)
         //firestoreViewModel.closeListeners(FirestoreListener.all())
         //firestoreViewModel.releaseData(FirestoreData.all())
     @unknown default:
         debugLog(object:"Unknown Future Options")
   }
 }
 */

struct MainView: View{
    @EnvironmentObject var firebaseAuth: FirebaseAuth
    @StateObject private var firestoreViewModel: FirestoreViewModel
    @StateObject var tubeViewModel = TubeViewModel()
    @StateObject var globalDialogPresentation = GlobalLoadingPresentation()
    @StateObject var navigationViewModel = NavigationViewModel()
    
    init() {
        self._firestoreViewModel = StateObject(wrappedValue: FirestoreViewModel())
    }
    
    // MARK: TAB MENU DEFAULT
    @ViewBuilder
    var mainContentTabView:some View{
        if firebaseAuth.loggedInAs == .ANONYMOUS_USER{
            tabMenuAnonymous
        }
        else{
            tabMenuRegistred
            .onAppear{ setUserDataIfNeededData() }
        }
    }
    
    var tabMenuAnonymous: some View {
        TabView(selection:$navigationViewModel.selectedTab) {
            AnonymousModel2DView()
            .tabItem {
                Label("Model", systemImage: "rotate.3d")
            }
            .tag(MainTabItem.MODEL_2D_ANONYMOUS)
            CustomCalendarView()
            .tabItem {
                Label("Calendar", systemImage: "calendar")
            }
            .tag(MainTabItem.CALENDAR)
            AnonymousProfileView()
            .tabItem {
                Label("Register", systemImage: "person.fill")
            }
            .tag(MainTabItem.PROFILE_ANONYMOUS)
        }
    }
    
    var tabMenuRegistred: some View {
        TabView(selection:$navigationViewModel.selectedTab) {
            Model2DView()
            .tabItem {
                Label("Model", systemImage: "rotate.3d")
            }
            .tag(MainTabItem.MODEL_2D)
            CustomCalendarView()
            .tabItem {
                Label("Calendar", systemImage: "calendar")
            }
            .tag(MainTabItem.CALENDAR)
            ProfileView()
            .tabItem {
                Label("Profile", systemImage: "person.fill")
            }
            .tag(MainTabItem.PROFILE)
        }
    }
        
    var body: some View{
        mainContentTabView
        .onDisappear{ releaseData() }
        .globalLoadingDialog(presentationManager: globalDialogPresentation)
        .environmentObject(tubeViewModel)
        .environmentObject(firestoreViewModel)
        .environmentObject(navigationViewModel)
        .environmentObject(globalDialogPresentation)
        .ignoresSafeArea(.keyboard)
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
    }
     
}
