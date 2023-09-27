//
//  TopMenu.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-08-21.
//

import SwiftUI

struct TopMenu:View{
    let title:String
    let actionCloseButton: () -> Void
    
    var topMenu:  some View{
        VStack{
            HStack{
                topMenuHeaderCell.hLeading()
                Button("\(Image(systemName: BACK_BUTTON_PRIMARY))", action: actionCloseButton).font(.headline).hTrailing()
            }
            Divider()
        }
        .frame(height:MENU_HEIGHT)
        .padding()
    }
    
    var topMenuHeaderCell: some View{
        Text(title)
        .font(.headline)
        .foregroundStyle(.primary)
    }
    
    var body: some View{
        topMenu
    }
}

