//
//  TubeDocFileView.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-09-21.
//

import SwiftUI

struct TubeDocFileView:View{
    let tube:TubeModel
    let onSelected:(TubeModel) -> Void
    
    var docFileImage:some View{
        ZStack{
            Image(systemName: "doc").resizable().scaledToFill()
        }
        .frame(width: 35.0,height: 50.0)
        .padding()
        .background(
           RoundedRectangle(cornerRadius: 8).fill(Color.white)
        )
        .overlay{
            RoundedRectangle(cornerRadius: 8).stroke(lineWidth: 2.0).foregroundColor(.systemGray)
        }
    }
    
    @ViewBuilder
    var tubeDate: some View{
        if let date = tube.date{
            Text(date.shortTime())
            .font(.subheadline)
            .foregroundColor(.systemGray)
        }
    }
    
    @ViewBuilder
    var tubeMessage: some View{
        if let message = tube.message{
            Text(message)
            .font(.callout)
            .bold()
            .lineLimit(1)
            .foregroundColor(.white)
        }
     }
    
    
    var tubeBody: some View{
        VStack{
            docFileImage
            tubeMessage
            tubeDate
        }
        
     }
   
    var tubeInfo: some View{
        tubeBody
        .contentShape(Rectangle())
        .onTapGesture {
            onSelected(tube)
        }
    }
    
    
    var body:some View{
        tubeBody
        .contentShape(Rectangle())
        .onTapGesture {
            onSelected(tube)
        }
    }
}


struct ExtendedTubeDocFileView:View{
    @Binding var userWillEditTubes:Bool
    let tube:TubeModel
    let onSelected:(TubeModel) -> Void
    let onToggleListWithId:(String?) -> Void
    let onListContainsId:(String?) -> Bool
    let childViewHeight:CGFloat
    
    var checkmarkCircle:some View{
        Image(systemName: "checkmark.circle.fill")
        .resizable()
        .background{
            Circle().fill(Color.white).frame(width: 26, height: 26)
        }
        .foregroundColor(Color.backgroundPrimary)
    }
    
    @ViewBuilder
    var selectedToggleBox: some View{
        if onListContainsId(tube.id){
            checkmarkCircle
            .frame(width: 24, height: 24)
            .font(.system(size: 20, weight: .bold, design: .default))
            .hLeading()
            .vBottom()
            .padding([.leading,.bottom])
        }
    }
    
    var docFileImage:some View{
        ZStack{
            Image(systemName: "doc").resizable().scaledToFill()
        }
        .frame(width: 35.0,height: childViewHeight)
        .padding()
        .background(
           RoundedRectangle(cornerRadius: 8).fill(Color.white)
        )
        .overlay{
            RoundedRectangle(cornerRadius: 8).stroke(lineWidth: 2.0).foregroundColor(.systemGray)
        }
    }
    
    @ViewBuilder
    var tubeDate: some View{
        if let date = tube.date{
            Text(date.iosShortMessageFormat())
            .font(.subheadline)
            .foregroundColor(.systemGray)
        }
    }
    
    @ViewBuilder
    var tubeMessage: some View{
        if let message = tube.message{
            Text(message)
            .font(.callout)
            .bold()
            .lineLimit(1)
            .foregroundColor(.white)
        }
     }
    
    var tubeContent:some View{
        VStack{
            docFileImage
            tubeMessage
            tubeDate
        }
        .opacity(onListContainsId(tube.id) ? 0.5 : 1.0)
    }
    
    @ViewBuilder
    var tubeBody: some View{
        ZStack{
            tubeContent
            if userWillEditTubes {
                selectedToggleBox
             }
        }
    }
   
    var body:some View{
        tubeBody
        .contentShape(Rectangle())
        .onTapGesture {
            if !userWillEditTubes{
                onSelected(tube)
            }
            else{
                withAnimation{
                    onToggleListWithId(tube.id)
                }
            }
        }
    }
}

