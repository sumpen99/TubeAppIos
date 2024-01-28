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
    @StateObject private var firestoreViewModel: FirestoreViewModel
    @StateObject var tubeViewModel = TubeViewModel()
    @StateObject var globalDialogPresentation = GlobalLoadingPresentation()
    @StateObject var navigationViewModel = NavigationViewModel()
    
    init() {
        self._firestoreViewModel = StateObject(wrappedValue: FirestoreViewModel())
        self._tubeViewModel = StateObject(wrappedValue: TubeViewModel())
        self._globalDialogPresentation = StateObject(wrappedValue: GlobalLoadingPresentation())
        self._navigationViewModel = StateObject(wrappedValue: NavigationViewModel())
    }
    
    var tabMenu: some View {
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
        .onChange(of: navigationViewModel.selectedTab){ route in
            navigationViewModel.reset()
        }
    }
        
    var body: some View{
        tabMenu
        .onAppear{ setUserDataIfNeededData() }
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
        /*firestoreViewModel.checkIfUserDocumentExists(){ error,documentExists in
            if documentExists{ setupListenerForUserChanges() }
            else { setUpNewUser()}
        }*/
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
