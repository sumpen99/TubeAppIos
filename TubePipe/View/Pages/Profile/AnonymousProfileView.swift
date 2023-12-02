//
//  AnonymousProfileView.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-09-16.
//

import SwiftUI

struct AnonymousProfileView:View{
    
    var footerText:String = """
                                As a member you gain access to ex:
                                \(pointTab)Save and store tubes on device.
                                \(pointTab)Share tubes with other TubePipe users.
                            """
    
    var accountSection:some View{
        Section {
             navigateToRegisterPage
        } header: {
            Text("Account").listSectionHeader()
        } footer: {
            Text(footerText).listSectionFooter()
        }
    }
    
    var personalPage:some View{
        List{
            accountSection
        }
        .scrollDisabled(true)
        .listStyle(.insetGrouped)
    }
    
    var body: some View{
        NavigationStack{
            AppBackgroundStack(content: {
                personalPage
            },title: "Register")
        }
    }
    
    //MARK: NAVIGATIONBUTTONS
    var navigateToRegisterPage:some View{
        NavigationLink(destination:LazyDestination(destination: {
            SignupView()
        })){
            Text("Sign up").foregroundColor(Color.systemBlue).hCenter()
        }
    }
    
    var navigateToInfoPage:some View{
        NavigationLink(destination:LazyDestination(destination: {
            InfoView()
        })){
            Image(systemName: "info.circle").toolbarFontAndPadding()
        }
    }
    
}
