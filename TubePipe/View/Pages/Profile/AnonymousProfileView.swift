//
//  AnonymousProfileView.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-09-16.
//

import SwiftUI

enum AnonymousProfileAlertAction: Identifiable{
    case CREATE_ACCOUNT
    
    var id: Int {
        hashValue
    }
    
}

struct AnonymousProfileView:View{
    @EnvironmentObject var firebaseAuth: FirebaseAuth
    @State var profileAlertAction: AnonymousProfileAlertAction?
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
            .actionSheet(item: $profileAlertAction){ alert in
                switch alert{
                case .CREATE_ACCOUNT: return actionSheetLogout
                }
            }
        }
    }
    
    //MARK: ACTIONSHEET
    var actionSheetLogout:ActionSheet{
        ActionSheet(title: Text("Create Account"), message: Text("This action will take you back to the mainpage where you can create an account."), buttons: [
            .default(Text("OK, lets go!")) { firebaseAuth.signOut() },
            .cancel()
        ])
    }
    
    //MARK: NAVIGATIONBUTTONS
    var navigateToRegisterPage:some View{
        Button(action: { profileAlertAction = .CREATE_ACCOUNT}, label: {
            buttonAsNavigationLink(title: "Register",
                                   systemImage: "person.crop.circle.badge.plus",
                                   lblColor: .systemBlue,
                                   imgColor: .systemBlue)
        })
        .profileListRow()
    }
    
}
