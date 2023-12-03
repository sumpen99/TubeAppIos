//
//  ContentView.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-06-10.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var firebaseAuth:FirebaseAuth
    
    init(){
        UIView.changeUIAlertTintColor()
        UITabBar.changeAppearance()
        UINavigationBar.changeAppearance()
    }
    
    var body: some View {
        switch firebaseAuth.loggedInAs{
            case .NOT_LOGGED_IN:    
                WelcomeView()
            case .ANONYMOUS_USER:   
                MainAnonymousView()
            case .REGISTERED_USER:
                MainView()
            case .ADMIN_USER:       
                MainView()
        }
    }
    
}
