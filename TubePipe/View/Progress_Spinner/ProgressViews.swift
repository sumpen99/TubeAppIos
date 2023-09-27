//
//  ProgressViews.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-08-21.
//

import SwiftUI

struct AutoFillProgressView: View {
    @EnvironmentObject var dialogPresentation: DialogPresentation
    let presentedText:String
    var body: some View {
        GeometryReader{ reader in
            let scale = min(reader.size.width,reader.size.height) / 4.0
            let width = min(scale*2.5,250.0)
            let rad = scale / 6.0
            ZStack{
                Color.white
                HStack{
                    RingSpinner(size:scale)
                    if dialogPresentation.stopAnimating{
                        Text(dialogPresentation.presentedText).foregroundColor(Color.systemGreen).hLeading()
                    }
                }
            }
            .frame(width: width,height: scale)
            .cornerRadius(rad)
            .hCenter()
            .vCenter()
        }
    }
        
}

struct RingSpinner : View {
    @EnvironmentObject var dialogPresentation: DialogPresentation
    @State var stopAnimating:Bool = false
    @State var pct: Double = 0.0
    let size:CGFloat
    var animation: Animation {
        Animation.easeIn(duration: 1.5).repeatForever(autoreverses: false)
        
    }

    var body: some View {
        ZStack {
            Circle()
                .trim(from: 0.0, to: 1.0)
                .stroke(style: StrokeStyle(lineWidth: LINE_WIDTH_ANIMATED, lineCap: .round, lineJoin: .round))
                .opacity(0.3)
                .foregroundColor(Color.green)
                .rotationEffect(.degrees(90.0))
            InnerRing(pct: pct,stopAnimating: stopAnimating).stroke(Color.green, lineWidth: LINE_WIDTH_ANIMATED)
            if dialogPresentation.stopAnimating{
                Image(systemName: "checkmark")
                .resizable()
                .frame(width: size*0.3,height: size*0.3)
                .foregroundColor(Color.systemGreen)
                
            }
        }
        .padding()
        .frame(width: size,height: size)
        .hLeading()
        .onChange(of: dialogPresentation.stopAnimating){ isDone in
            if isDone{
                stopAnimation()
            }
            
        }
        .onAppear(){
            startAnimation()
        }
    }
    
    func startAnimation() {
         withAnimation(animation) {
            self.pct = 1.0
        }
    }
    
    func stopAnimation(){
        withAnimation{
            stopAnimating = true
        }
    }
    
}

struct InnerRing : Shape {
    var pct: Double
    var stopAnimating:Bool
    let lagAmmount = 0.35
       
    
    func path(in rect: CGRect) -> Path {
        let end = pct * 360
        var start: Double
      
        if pct > (1 - lagAmmount) {
            start = 360 * (2 * pct - 1.0)
        } else if pct > lagAmmount {
            start = 360 * (pct - lagAmmount)
        } else {
            start = 0
        }
        var p = Path()
        p.addArc(center: CGPoint(x: rect.size.width/2, y: rect.size.width/2),
                 radius: rect.size.width/2,
                 startAngle: Angle(degrees: stopAnimating ? 0.0 : start),
                 endAngle: Angle(degrees: stopAnimating ? 360.0 : end),
                 clockwise: false)

        return p
    }
    
    var animatableData: Double {
        get { return pct }
        set { pct = newValue }
    }
    
}

