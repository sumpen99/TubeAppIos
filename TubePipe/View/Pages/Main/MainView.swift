//
//  MainView.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-06-10.
//

import SwiftUI

struct MainView: View{
    @EnvironmentObject var firebaseAuth: FirebaseAuth
    @StateObject private var firestoreViewModel: FirestoreViewModel
    @StateObject var tubeViewModel = TubeViewModel()
    @StateObject var globalDialogPresentation = GlobalLoadingPresentation()
    @StateObject var navigationViewModel = NavigationViewModel()
    
    init() {
        self._firestoreViewModel = StateObject(wrappedValue: FirestoreViewModel())
    }
    
    // MARK: TAB MENU CUSTOM
    let layoutRegistred = [
            GridItem(.flexible(minimum: 40)),
            GridItem(.flexible(minimum: 40)),
            GridItem(.flexible(minimum: 40)),
    ]
 
    let layoutAnonymous = [
            GridItem(.flexible(minimum: 40)),
            GridItem(.flexible(minimum: 40)),
    ]
     
    func menuItem(tabItem:MainTabItem,img:String,label:String) -> some View{
        return Button(action: {
            navigationViewModel.navTo(tabItem)
        }, label: {
            VStack(spacing:10){
                Image(systemName: img).font(.title2)
                Text(label).font(.caption)
            }
            .foregroundColor(navigationViewModel.isActive(tabItem) ? Color.accentColor : Color.systemGray)
        })
    }
    
    var anonymousMenu:some View{
        VStack{
            SplitLineProgressView(isLoading: $globalDialogPresentation.isLoading)
            LazyVGrid(columns: layoutAnonymous, pinnedViews: [.sectionHeaders]){
                menuItem(tabItem: MainTabItem.MODEL_2D_ANONYMOUS, img: "house.fill", label: "Model")
                menuItem(tabItem: MainTabItem.PROFILE_ANONYMOUS, img: "person.fill", label: "Profile")
            }
        }
        .background(Color.backgroundSecondary)
        .hLeading()
    }
    
    var registredMenu:some View{
        VStack{
            SplitLineProgressView(isLoading: $globalDialogPresentation.isLoading)
            LazyVGrid(columns: layoutRegistred,pinnedViews: [.sectionHeaders]){
                menuItem(tabItem: MainTabItem.MODEL_2D, img: "house.fill", label: "Model")
                menuItem(tabItem: MainTabItem.CALENDAR, img: "calendar", label: "Calendar")
                menuItem(tabItem: MainTabItem.PROFILE, img: "person.fill", label: "Profile")
            }
        }
        .background(Color.backgroundSecondary)
        .hLeading()
    }
    
    @ViewBuilder
    var mainContent:some View{
        ZStack{
            switch navigationViewModel.selectedTab{
            case .MODEL_2D:                 Model2DView()
            case .CALENDAR:                 CustomCalendarView()
            case .PROFILE:                  ProfileView()
            case .PROFILE_ANONYMOUS:        AnonymousProfileView()
            case .MODEL_2D_ANONYMOUS:       AnonymousModel2DView()
            }
        }
        .safeAreaInset(edge: .bottom){ bottomMenu }
        .globalLoadingDialog(presentationManager: globalDialogPresentation)
    }
    
    @ViewBuilder
    var bottomMenu: some View{
        if firebaseAuth.loggedInAs == .ANONYMOUS_USER{
            tabMenuAnonymous
        }
        else{
            registredMenu
        }
        
    }
    
    // MARK: TAB MENU DEFAULT
    @ViewBuilder
    var mainContentTabView:some View{
        if firebaseAuth.loggedInAs == .ANONYMOUS_USER{
            tabMenuAnonymous
        }
        else{
            tabMenuRegistred
        }
    }
    
    var tabMenuAnonymous: some View {
        TabView(selection:$navigationViewModel.selectedTab) {
            AnonymousModel2DView()
            .tabItem {
                Label("Model", systemImage: "rotate.3d")
            }
            .tag(MainTabItem.MODEL_2D_ANONYMOUS)
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
