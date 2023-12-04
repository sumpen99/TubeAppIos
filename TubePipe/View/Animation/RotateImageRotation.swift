//
//  RotateImageRotation.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-10-06.
//

import SwiftUI

struct RotateImageView:View{
    @Binding var isActive:Bool
    let name:String
    @State var isAnimating = false
    
    var singleAnimation: Animation {
        Animation.linear(duration: 0.3)
    }

    var body: some View {
        Image(name)
        .resizable()
        .foregroundColor(isActive ? Color.accentColor : Color.systemGray)
        .rotationEffect(Angle.degrees(isAnimating ? 360 : 0))
        .onChange(of: isActive){ active in
            startAnimation()
        }
    }
    
    func startAnimation() {
        withAnimation(singleAnimation) {
            isAnimating = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0){
                isAnimating = false
            }
        }
    }
   
}

struct RotateImageViewDefault:View{
    let name:String
    @State var isAnimating = false
    
    var singleAnimation: Animation {
        Animation.linear(duration: 0.7)
    }

    var body: some View {
        Image(systemName: name)
        .foregroundColor(Color.accentColor)
        .rotationEffect(Angle.degrees(isAnimating ? 360 : 0))
        .onAppear {
            startAnimation()
        }
    }
    
    func startAnimation() {
        withAnimation(singleAnimation) {
            isAnimating = true
        }
    }
   
}
