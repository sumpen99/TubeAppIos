//
//  TubeDocFileView.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-09-21.
//

import SwiftUI

struct DocFileImage:View{
    let showStaroFill:Bool
    
    var body:some View{
        ZStack{
            Image(systemName: "doc").resizable().scaledToFill()
        }
        .frame(width: 35.0,height: 50.0)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8).fill(Color.systemYellow.opacity(0.7))
        )
        .overlay{
            RoundedRectangle(cornerRadius: 8).stroke(lineWidth: 2.0).foregroundColor(.black)
            if showStaroFill{
                Image(systemName: "staroflife.fill")
                .resizable()
                .frame(width: 10,height:10)
                .hTrailing()
                .vTop()
                .padding([.trailing,.top],2)
             }
         }
    }
}

struct TubeDocFileView:View{
    let tube:TubeModel
    let onSelected:(TubeModel) -> Void
    
    var showStaroFill:Bool{
        (tube.from ?? USER_IDENTIFIER_COREDATA) != USER_IDENTIFIER_COREDATA
    }
        
    @ViewBuilder
    var tubeDate: some View{
        if let date = tube.date{
            Text(date.shortTime())
            .font(.footnote)
            .foregroundColor(.black)
        }
    }
    
    @ViewBuilder
    var tubeMessage: some View{
        if let message = tube.message{
            Text(message)
            .font(.subheadline)
            .bold()
            .lineLimit(1)
            .foregroundColor(.black)
        }
     }
    
    
    var tubeBody: some View{
        VStack{
            DocFileImage(showStaroFill: showStaroFill)
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
    var showStaroFill:Bool{
        (tube.from ?? USER_IDENTIFIER_COREDATA) != USER_IDENTIFIER_COREDATA
    }
    
    var checkmarkCircle:some View{
        Image(systemName: "checkmark.circle.fill")
        .resizable()
        .background{
            Circle().fill(Color.black).frame(width: 26, height: 26)
        }
        .foregroundColor(Color.white)
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
    
    @ViewBuilder
    var tubeDate: some View{
        if let date = tube.date{
            Text(date.iosShortMessageFormat())
            .font(.footnote)
            .foregroundColor(.black)
        }
    }
    
    @ViewBuilder
    var tubeMessage: some View{
        if let message = tube.message{
            Text(message)
            .font(.subheadline)
            .bold()
            .lineLimit(1)
            .foregroundColor(.black)
        }
     }
    
    var tubeContent:some View{
        VStack{
            DocFileImage(showStaroFill: showStaroFill)
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
            else{ onToggleListWithId(tube.id) }
        }
    }
}

