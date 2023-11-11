//
//  MainView.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-06-10.
//

import SwiftUI

struct MainView: View{
    @EnvironmentObject var firebaseAuth: FirebaseAuth
    @EnvironmentObject var firestoreViewModel: FirestoreViewModel
    @StateObject var tubeViewModel = TubeViewModel()
    @StateObject var globalDialogPresentation = GlobalLoadingPresentation()
    @StateObject var coreDataViewModel = CoreDataViewModel()
    @StateObject var navigationViewModel = NavigationViewModel()
    
    let layoutRegistred = [
            GridItem(.flexible(minimum: 40)),
            GridItem(.flexible(minimum: 40)),
            GridItem(.flexible(minimum: 40)),
            GridItem(.flexible(minimum: 40)),
    ]
    let layoutAnonymous = [
            GridItem(.flexible(minimum: 40)),
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
                menuItem(tabItem: MainTabItem.HOME_ANONYMOUS, img: "house.fill", label: "Home")
                menuItem(tabItem: MainTabItem.MODEL, img: "rotate.3d", label: "Model")
                menuItem(tabItem: MainTabItem.PROFILE_ANONYMOUS, img: "person.fill", label: "Profile")
            }
        }
        .background(Color.backgroundPrimary)
        .hLeading()
    }
    
    var registredMenu:some View{
        VStack{
            SplitLineProgressView(isLoading: $globalDialogPresentation.isLoading)
            LazyVGrid(columns: layoutRegistred,pinnedViews: [.sectionHeaders]){
                menuItem(tabItem: MainTabItem.HOME, img: "house.fill", label: "Home")
                menuItem(tabItem: MainTabItem.MODEL, img: "rotate.3d", label: "Model")
                menuItem(tabItem: MainTabItem.CALENDAR, img: "calendar", label: "Calendar")
                menuItem(tabItem: MainTabItem.PROFILE, img: "person.fill", label: "Profile")
            }
        }
        .background(Color.backgroundPrimary)
        .hLeading()
    }
    
    @ViewBuilder
    var mainContent:some View{
        ZStack{
            switch navigationViewModel.selectedTab{
            case .HOME:                 HomeView()
            case .MODEL:                ModelView()
            case .CALENDAR:             CustomCalendarView()
            case .PROFILE:              ProfileView()
            case .PROFILE_ANONYMOUS:    AnonymousProfileView()
            case .HOME_ANONYMOUS:       AnonymousHomeView()
            }
        }
        .safeAreaInset(edge: .bottom){ bottomMenu }
        .globalLoadingDialog(presentationManager: globalDialogPresentation)
    }
    
    @ViewBuilder
    var bottomMenu: some View{
        if firebaseAuth.loggedInAs == .ANONYMOUS_USER{
            anonymousMenu
        }
        else{
            registredMenu
        }
        
    }
    
    
    var body: some View{
        mainContent
        .ignoresSafeArea(.keyboard)
        .environmentObject(coreDataViewModel)
        .environmentObject(tubeViewModel)
        .environmentObject(navigationViewModel)
        .environmentObject(globalDialogPresentation)
    }
    
}
