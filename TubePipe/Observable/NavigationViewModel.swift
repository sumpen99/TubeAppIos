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
    @Published var pathTo:NavigationPath = NavigationPath()
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
    
    func switchRouteTo(_ route:ProfileRoute){
        if pathTo.count > 0{
            pathTo.removeLast(pathTo.count)
        }
        pathTo.append(route)
    }
    
    func replaceRouteWith(_ contact:Contact){
        if pathTo.count > 0{
            pathTo.removeLast(pathTo.count)
        }
        pathTo.append(contact)
    }
    
    func appendToPathWith(contact toShow:Contact){
        pathTo.append(toShow)
    }
    
    func clearPath(){
        pathTo.removeLast(pathTo.count)
    }
    
    
}
