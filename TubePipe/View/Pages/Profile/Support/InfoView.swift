//
//  InfoView.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-09-16.
//

import SwiftUI

let pointTab:String = "•\t"
struct InfoView:View{
    var guestText:String = """
                            \(pointTab)Build tube in 2d
                            \(pointTab)Render tube as 3d scene
                            \(pointTab)View tube details
                            """
    var memberText:String = """
                            \(pointTab)Save tubes & attached image on device
                            \(pointTab)Share tubes & attached images with other TubePipe users
                            \(pointTab)Upcoming features from developers of TubePipe such as augmented reality...
                            """
    
    var infoLabel:some View{
        Text("USERMODES").font(.title).bold().hLeading()
        .foregroundColor(Color.GHOSTWHITE)
        .padding()
    }
    
    var sectionGuest:some View{
        Section {
            Text(guestText).foregroundColor(.black)
        } header: {
            Text("Guest").foregroundColor(.white).bold()
        }
    }
    
    var sectionMember:some View{
        Section {
            Text(memberText).foregroundColor(.black)
        } header: {
            Text("Member").foregroundColor(.white).bold()
        }
    }
    
    var sectionRegistred:some View{
        Section {
            Text(memberText).foregroundColor(.black)
        } header: {
            Text("Member").foregroundColor(.white).bold()
        }
    }
    
    var infoBody:some View{
        VStack(spacing:0){
            infoLabel
            List{
                sectionGuest
                sectionRegistred
            }
            .listStyle(.insetGrouped)
        }
        
    }
    
    var body:some View{
        AppBackgroundStack(content: {
            infoBody
        })
        .modifier(NavigationViewModifier(title: ""))
        .hiddenBackButtonWithCustomTitle("Ok, gotcha!")
    }
}
