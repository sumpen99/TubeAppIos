//
//  HeaderSubHeaderStructs.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-08-20.
//

import SwiftUI

struct HeaderSubHeaderWithClearOption:View{
    let header:String
    let subHeader:String
    var action:(() -> Void)? = nil
    
    var body:some View{
        HStack{
            Text(header)
            Text(subHeader).font(.body)
            Spacer()
            Button(action: { action?() },label: {
                //Text("Rensa").foregroundColor(Color.systemBlue)
                Image(systemName: "xmark.circle")
            })
            .padding(.trailing)
        }
        .foregroundColor(Color.systemGray)
        .hLeading()
    }
    
}

struct VertHeaderMessage:View{
    let header:String
    let message:String
    
    var body:some View{
        VStack(spacing:2){
            Text(header)
                .font(.headline).bold()
                .hLeading()
            Text(message).font(.body).hLeading()
            //Spacer()
       }
        .foregroundColor(Color.systemGray)
        .hLeading()
        .padding([.leading,.bottom],5)
    }
    
    
}

struct HeaderSubHeader:View{
    let header:String
    let subHeader:String
    let lblColor:Color
    
    var body:some View{
        HStack{
            Text(header).font(.caption).bold().lineLimit(1)
            Text(subHeader).font(.caption).lineLimit(1)
            Spacer()
        }
        .foregroundColor(lblColor)
        .hLeading()
    }
    
    
}

struct HeaderSubHeaderView: View{
    let header:String
    let subHeader:String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(header).font(.headline)
            Text(subHeader).font(.callout)
        }.hLeading()
    }
}

struct SubHeaderSubHeaderView: View{
    let subMain:Text
    let subSecond:Text
    
    var body: some View {
        HStack{
            subMain.hLeading()
            subSecond.hTrailing()
        }
    }
}

struct BoldSubHeaderSubHeaderView: View{
    let subMain:Text
    let subSecond:Text
    
    var body: some View {
        HStack{
            subMain.font(.body).hLeading()
            subSecond.font(.callout).hTrailing()
        }
        .padding()
    }
}

struct SubHeaderSubHeaderLeadingView: View{
    let subMain:Text
    let subSecond:Text
    
    var body: some View {
        VStack{
            subMain.font(.headline).hLeading()
            subSecond.font(.body).hLeading()
        }
        .padding()
    }
}
