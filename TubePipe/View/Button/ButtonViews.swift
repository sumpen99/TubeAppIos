//
//  ButtonViews.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-08-21.
//

import SwiftUI

struct TapAndHoldButton: View{
    let tapAction: (Any) -> Void
    let holdAction: () -> Void
    let imageName:String
    var color:Color = Color.systemBlue
    @GestureState var pressingState = false
  
    var body: some View{
        Button(action: {} ){
            Image(systemName: imageName)
            .font(.title)
            .bold()
            .foregroundColor(.white)
            .padding()
            .background(color)
            .frame(width: 36,height:36)
            .clipShape(Circle())
         }
        .background(Group { if self.pressingState { TimeEventGeneratorView(callback: holdAction) }})
        .simultaneousGesture(
            LongPressGesture(minimumDuration: 0.1)
                .sequenced(before: LongPressGesture(minimumDuration: .infinity))
                .updating($pressingState){ value, state, transaction in
                    switch value {
                        case .second(true, nil):
                            state = true
                        default:
                            break
                    }
                }
         )
        .highPriorityGesture(
            TapGesture()
                .onEnded(tapAction)
        )
    }
    
}

struct BackButton:View{
    @Environment(\.dismiss) private var dismiss
    var title:String = "Back"
    var color:Color = Color.systemBlue
    
    var body: some View{
        HStack{
            Button(action:{ dismiss()}) {
                HStack(spacing: 5){
                    Image(systemName: "chevron.left").bold()
                    Text(title)
                }
                .foregroundColor(color)
            }
        }
    }
}
