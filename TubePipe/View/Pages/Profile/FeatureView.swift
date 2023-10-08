//
//  FeatureView.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-10-08.
//

import SwiftUI

struct FeatureView:View{
    
    
    var featureLabel:some View{
        Text("REQUEST FEATURE").font(.title).bold().hLeading()
        .foregroundColor(Color.GHOSTWHITE)
        .padding()
    }
    
    var featureImage:some View{
        Image(systemName: "lightbulb").foregroundColor(.yellow).hCenter().font(.largeTitle)
    }
    
    var infoBody:some View{
        VStack(spacing:0){
            featureLabel
            featureImage
            List{
                
            }
            .listStyle(.insetGrouped)
        }
        
    }
    
    var body:some View{
        NavigationView{
            AppBackgroundStack(content: {
                infoBody
            })
            .modifier(NavigationViewModifier(title: ""))
        }
        .hiddenBackButtonWithCustomTitle("Profile")
    }
}
