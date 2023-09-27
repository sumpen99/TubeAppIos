//
//  ToggleViews.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-08-20.
//

import SwiftUI

struct ToggleBox: View{
    @Binding var toogleIsOn:Bool
    let label:String
    let image:Image?
    var body: some View{
        HStack{
            image
            Text(label)
            Spacer()
            Image(systemName: toogleIsOn ? "chevron.up" : "chevron.down")
        }
        .foregroundColor(Color.systemBlue)
        .onTapGesture{
            withAnimation{
                toogleIsOn.toggle()
            }
        }
        .padding(.trailing)
    }
}
