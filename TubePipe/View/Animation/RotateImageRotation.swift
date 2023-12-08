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
        .rotationEffect(Angle.degrees(isAnimating ? 360 : 0))
        .onChange(of: isActive){ active in
            toggleAnimation()
        }
        
    }
    
    func toggleAnimation() {
        withAnimation(singleAnimation) {
            if isActive{
                isAnimating.toggle()
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
