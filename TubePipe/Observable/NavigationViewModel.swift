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
}

class NavigationViewModel: ObservableObject{
    @Published var selectedTab:MainTabItem = .HOME
    
    func navTo(_ tab:MainTabItem){
        selectedTab = tab
    }
    
    func isActive(_ tab:MainTabItem) -> Bool{
        return selectedTab == tab
    }
}
