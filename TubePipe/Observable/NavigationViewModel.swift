//
//  NavigationViewModel.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-09-06.
//

import SwiftUI

enum MainTabItem{
    case HOME
    case MODEL
    case CALENDAR
    case PROFILE
    case PROFILE_ANONYMOUS
    case HOME_ANONYMOUS
}

class NavigationViewModel: ObservableObject{
    @Published var selectedTab:MainTabItem = .HOME
    var delayNavigation:Bool = false
    var executeBevoreNavigation:(() ->Void)? = nil
    
    func navTo(_ tab:MainTabItem){
        if(isActive(tab)){NavigationUtil.popToRootView()}
        else{nav(tab)}
    }
    
    private func nav(_ tab:MainTabItem){
        DispatchQueue.main.async {
            self.selectedTab = tab
        }
    }
    
    func isActive(_ tab:MainTabItem) -> Bool{
        return selectedTab == tab
    }
    
}
