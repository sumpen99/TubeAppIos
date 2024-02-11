//  ContentView.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-06-10.
//

import SwiftUI

struct ContentViewDev: View {
   
    init(){
        UIView.changeUIAlertTintColor()
        UITabBar.changeAppearance()
        UINavigationBar.changeAppearance()
    }
    
    var test:some View{
        NavigationStack{
            ModelArView()
        }
    }
    
    var body:some View{
        TabView{
            test
            .tabItem {
                Label("Model", systemImage: "rotate.3d")
            }
        }
    }
     
}
