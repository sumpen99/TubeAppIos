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
    
    var notEmptyPath:Bool{ pathTo.count > 0 }
    
    func navTo(_ tab:MainTabItem){
        if(isActive(tab)){NavigationUtil.popToRootView()}
        else{nav(tab)}
    }
    
    private func nav(_ tab:MainTabItem){
        DispatchQueue.main.async {
            self.clearPath()
            self.selectedTab = tab
        }
    }
    
    func isActive(_ tab:MainTabItem) -> Bool{
        return selectedTab == tab
    }
    
    func switchPathToRoute(_ route:ProfileRoute){
        clearPath()
        pathTo.append(route)
    }
    
    func appendToPathWithContact(_ contact:Contact){
        pathTo.append(contact)
    }
    
    func appendToPathWithMessage(_ message:Message){
        pathTo.append(message)
    }
    
    func clearPath(){
        if notEmptyPath{ pathTo.removeLast(pathTo.count) }
    }
    
    func popPath(){
        if notEmptyPath{ pathTo.removeLast() }
    }
        
}
