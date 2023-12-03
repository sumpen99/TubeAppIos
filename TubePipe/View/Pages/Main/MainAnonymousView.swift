//
//  MainView.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-12-03.
//

import SwiftUI

struct MainAnonymousView: View{
    @StateObject var tubeViewModel: TubeViewModel
    @StateObject var globalDialogPresentation: GlobalLoadingPresentation
    @StateObject var navigationViewModel: NavigationViewModel
    
    init(){
        self._tubeViewModel = StateObject(wrappedValue: TubeViewModel())
        self._globalDialogPresentation = StateObject(wrappedValue: GlobalLoadingPresentation())
        self._navigationViewModel = StateObject(wrappedValue: NavigationViewModel())
    }
    
    var tabMenu: some View {
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
        
    var body: some View{
        tabMenu
        .globalLoadingDialog(presentationManager: globalDialogPresentation)
        .environmentObject(tubeViewModel)
        .environmentObject(navigationViewModel)
        .environmentObject(globalDialogPresentation)
        .ignoresSafeArea(.keyboard)
    }
    
}
