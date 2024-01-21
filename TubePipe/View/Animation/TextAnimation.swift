//
//  TextAnimation.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-09-16.
//

import SwiftUI

struct BouncingText:View{
    @Binding var isAnimating:Bool
    let text:String
    let color:Color
    
    var foreverAnimation: Animation {
        Animation.linear(duration: 0.7)
        .repeatForever()
    }

    var body: some View {
        Text(text)
        .foregroundStyle(color)
        .scaleEffect(isAnimating ? 1.2 : 1)
        .onAppear {
            startAnimation()
        }
    }
    
    func startAnimation() {
        withAnimation(foreverAnimation) {
             self.isAnimating = true
        }
    }
}
