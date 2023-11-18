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
        Section {
            navigateToRegisterPage
        } header: {
            Text("Account").foregroundColor(.black).bold()
        } footer: {
            Text(footerText).listSectionFooter()
        }
    }
    
    var personalPage:some View{
        List{
            accountSection
        }
        .listStyle(.insetGrouped)
    }
    
    var body: some View{
        AppBackgroundStack(content: {
            personalPage
        })
        .toolbar {
             ToolbarItem(placement: .navigationBarTrailing) {
                 navigateToInfoPage
                 .toolbarFontAndPadding()
             }
        }
    }
    
    //MARK: NAVIGATIONBUTTONS
    var navigateToRegisterPage:some View{
        NavigationLink(destination:LazyDestination(destination: {
            SignupView()
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
