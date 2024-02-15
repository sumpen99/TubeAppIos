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
            .foregroundStyle(.white)
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

struct RoundedButton: View{
    let action: () -> Void
    let imageName:String
    let radius:CGFloat
    let color:Color
    let font:Font
   
    var body: some View{
        Button(action: action ){
            Image(systemName: imageName)
            .font(font)
            .bold()
            .foregroundStyle(.white)
            .padding()
            .background(color)
            .frame(width: radius,height:radius)
            .clipShape(Circle())
         }
    }
    
}

struct BackButton:View{
    @Environment(\.dismiss) private var dismiss
    var title:String = "Back"
    var imgLabel:String = "chevron.left"
    var color:Color = Color.accentColor
    var action: (() -> Void)? = nil
    
    var body: some View{
        HStack{
            Button(action:{
                action?()
                dismiss()
            }){
                HStack(spacing: 5){
                    Image(systemName: imgLabel).font(.headline)
                    //Text(title)
                }
                .foregroundStyle(color)
            }
        }
    }
}

struct LabelButton:View{
    let title:String
    let imgLabel:String
    
    var body: some View{
        HStack{
            Image(systemName: imgLabel)
                .font(.title2)
            //Text(title).hCenter()
                //.font(.title2)
        }
    }
}

struct IsOnButton<T:Equatable>:View,ButtonIsOn{
    @Binding var isOn:T?
    let identity:T
    let imgLabel:String
    let action:(() ->Void)?
    
    var body: some View{
        Button(action: execAction){
            Image(systemName: imgLabel)
                .foregroundStyle(buttonIsOn ? Color.systemBlue : Color.tertiaryLabel)
        }
    }
    
    var buttonIsOn:Bool{
        isOn == identity
    }
    
    func execAction(){
        (isOn != identity) ? (isOn = identity) : (isOn = nil)
        action?()
    }
}

struct SpinnerButton:View {
    @Binding var isTimeout:Bool
    let action: () -> Void
    let label:String
    
    var body: some View {
        Button(action:action,label: {
            if isTimeout{
                ProgressView().hCenter()
            }
            else{
                Text(label).hCenter()
            }
        })
    }
}
