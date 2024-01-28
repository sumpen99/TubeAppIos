//
//  NavigationViewModel.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-09-06.
//

import SwiftUI

enum MainTabItem{
    case MODEL_2D
    case CALENDAR
    case PROFILE
    case PROFILE_ANONYMOUS
    case MODEL_2D_ANONYMOUS
}

class NavigationViewModel: ObservableObject{
    @Published var selectedTab:MainTabItem = .MODEL_2D
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
    
    func switchPathToRoute<T:Hashable>(_ route:T){
        clearPath()
        pathTo.append(route)
    }
    
    func appendToPathWith<T:Hashable>(_ t:T){
        pathTo.append(t)
    }
    
    func clearPath(){
        if notEmptyPath{ pathTo.removeLast(pathTo.count) }
    }
    
    func popPath(){
        if notEmptyPath{ pathTo.removeLast() }
    }
    
    func reset(){
        if notEmptyPath{
            pathTo.removeLast(pathTo.count)
            NavigationUtil.popToRootView()
            
        }
    }
        
}
