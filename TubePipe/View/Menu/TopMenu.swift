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
                //"\(Image(systemName: BACK_BUTTON_PRIMARY))"
                Button(action: actionCloseButton){
                    Image(systemName: "arrow.down")
                }
                .font(.headline)
                //.foregroundColor(Color.sheetCloseButton)
                .hTrailing()
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
        .lineLimit(1)
    }
    
    var body: some View{
        topMenu
    }
}

