//
//  AnonymousProfileView.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-09-16.
//

import SwiftUI

struct AnonymousProfileView:View{
    
    var footerText:String = "Navigate to information page and have a look at the benefits of joining the TubePipe community."
    
    var accountSection:some View{
        Section(header:Text("Account").foregroundColor(.white).bold(),
                footer: Text(footerText).foregroundColor(.white),
                content: {
                    navigateToRegisterPage
        })
    }
    
    var personalPage:some View{
        List{
            accountSection
        }
        .listStyle(.insetGrouped)
    }
    
    var body: some View{
        NavigationView{
            AppBackgroundStack(content: {
                personalPage
            })
            .toolbar {
                 ToolbarItem(placement: .navigationBarTrailing) {
                     navigateToInfoPage
                 }
            }
            .modifier(NavigationViewModifier(title: ""))
        }
    }
    
    //MARK: NAVIGATIONBUTTONS
    var navigateToRegisterPage:some View{
        NavigationLink(destination:LazyDestination(destination: {
            SignupView(backButtonColor: Color.systemBlue)
        })){
            Text("Register").foregroundColor(Color.systemBlue).hCenter()
        }
    }
    
    var navigateToInfoPage:some View{
        NavigationLink(destination:LazyDestination(destination: {
            InfoView()
        })){
            Image(systemName: "info.circle")
        }
    }
    
}