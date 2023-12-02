//
//  AnonymousProfileView.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-09-16.
//

import SwiftUI

struct AnonymousProfileView:View{
    
    var footerText:String = """
                                Create a free account and gain access to:
                                \(pointTab)Model in 3D.
                                \(pointTab)Model up to 100 segments.
                                \(pointTab)Save and store tubemodels on device.
                                \(pointTab)Connect with other TubePipe users.
                                \(pointTab)Share tubemodels with other TubePipe users.
                                \(pointTab)And more...
                            """
    
    var accountSection:some View{
        Section {
             navigateToRegisterPage
        } header: {
            Text("").listSectionHeader()
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
            },title: "Account")
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
