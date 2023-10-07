//
//  GlobalLoading.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-10-07.
//

import SwiftUI

let ANIMATION_DURATION:CGFloat = 0.7
let SHOW_CHECKMARK_AFTER_ANIMATION:CGFloat = ANIMATION_DURATION + 0.3

enum GlobalDialogContent: View {
    case globalAutoFillProgressView
    
    @ViewBuilder
    var body: some View {
        switch self {
        case .globalAutoFillProgressView:  GlobalAutoFillProgressView()
        }
    }
    
}

extension View{
    func globalLoadingDialog(presentationManager: GlobalLoadingPresentation) -> some View {
        self.modifier(GlobalLoadingDialog(presentationManager: presentationManager))
    }
}

final class GlobalLoadingPresentation: ObservableObject {
    @Published var isLoading = false
    @Published var isPresented = false
    @Published var dialogContent: GlobalDialogContent?
  
    func startLoading(){
        withAnimation{
            isLoading = true
        }
     }
    
    func stopLoading(){
        withAnimation{
            isLoading = false
            show(content: .globalAutoFillProgressView)
        }
    }
    
    func close(){
        isPresented = false
    }
    
    private func show(content: GlobalDialogContent?) {
        withAnimation{
            if let presentDialog = content {
                dialogContent = presentDialog
                isPresented = true
            } else {
                isPresented = false
            }
        }
    }
    
}

struct GlobalLoadingDialog:ViewModifier{
    @ObservedObject var presentationManager: GlobalLoadingPresentation
   
    func body(content: Content) -> some View {
        ZStack {
            content
            if presentationManager.isPresented {
                Rectangle().foregroundColor(Color.black.opacity(0.3))
                .edgesIgnoringSafeArea(.all)
                presentationManager.dialogContent
                .padding()
            }
        }
    }
}

struct AnimatedPath:Shape{
    func path(in rect:CGRect) -> Path{
        debugLog(object: rect.minX)
        debugLog(object: rect.maxX)
        debugLog(object: rect.minY)
        debugLog(object: rect.maxY)
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.move(to: CGPoint(x: rect.maxX/2.0, y: rect.minY))
        path.move(to: CGPoint(x: rect.maxX, y: rect.maxY))
        return path
    }
}

struct AnimatedRectangle:View{
    
    @State private var percentage: CGFloat = .zero
    var body:some View{
        Rectangle()
        .trim(from: percentage/2.0,to: percentage)
        .stroke(Gradient(colors: [Color.green, .white]), lineWidth: 2.0)
        .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses:true), value: percentage)
        .onAppear {
            self.percentage = 0.5
        }
    }
}

struct SplitLineProgressView:View{
    @Binding var isLoading:Bool
    @State var isAnimating = false
    
    var singleAnimation: Animation {
        Animation.linear(duration: ANIMATION_DURATION).repeatForever()
    }
    
    var loadingLine:some View{
        AnimatedRectangle().frame(height: 1)
    }
    
    var baseLine:some View{
        splitLine
    }
    
    var body: some View {
        ZStack{
            if isLoading{ loadingLine}
            else{ baseLine }
        }
        .onChange(of: isLoading){ active in
            if(active){ startAnimation()}
            else{ stopAnimation() }
        }
        .onAppear{
            if(isLoading){ startAnimation() }
        }
    }
    
    func startAnimation() {
        withAnimation(singleAnimation) {
            isAnimating = true
        }
    }
    
    func stopAnimation(){
        withAnimation{
            isAnimating = false
        }
    }
   
}

struct GlobalAutoFillProgressView: View {
    var body: some View {
        GeometryReader{ reader in
            let scale = min(reader.size.width,reader.size.height) / 4.0
            let width = min(scale*2.5,250.0)
            let rad = scale / 6.0
            ZStack{
                Color.white
                HStack{
                    GlobalRingSpinner(size:scale)
                }
            }
            .allowsHitTesting(false)
            .ignoresSafeArea(.all)
            .frame(width: width,height: scale)
            .cornerRadius(rad)
            .hCenter()
            .vCenter()
        }
    }
}

struct GlobalRingSpinner : View {
    @EnvironmentObject var globalLoadingPresentation: GlobalLoadingPresentation
    @State var pct: Double = 0.0
    @State var stopAnimating: Bool = false
    let size:CGFloat
    
    var animation: Animation {
        Animation.easeIn(duration: ANIMATION_DURATION)
    }

    var body: some View {
        ZStack {
            Circle()
                .trim(from: 0.0, to: 1.0)
                .stroke(style: StrokeStyle(lineWidth: LINE_WIDTH_ANIMATED, lineCap: .round, lineJoin: .round))
                .opacity(0.3)
                .foregroundColor(Color.green)
                .rotationEffect(.degrees(90.0))
            GlobalInnerRing(stopAnimating: $stopAnimating,pct: pct)
            .stroke(Color.green, lineWidth: LINE_WIDTH_ANIMATED)
            if stopAnimating{
                Image(systemName: "checkmark")
                .resizable()
                .frame(width: size*0.3,height: size*0.3)
                .foregroundColor(Color.systemGreen)
                
            }
        }
        .padding()
        .frame(width: size,height: size)
        .hLeading()
        .onAppear(){
            startAnimation()
        }
    }
    
    func startAnimation() {
         withAnimation(animation) {
            self.pct = 1.0
            DispatchQueue.main.asyncAfter(deadline: .now() + ANIMATION_DURATION){
                stopAnimating = true
                closePresentationDialog()
             }
         }
    }
    
    func closePresentationDialog(){
        DispatchQueue.main.asyncAfter(deadline: .now() + SHOW_CHECKMARK_AFTER_ANIMATION){
            globalLoadingPresentation.close()
        }
     }
     
}

struct GlobalInnerRing : Shape {
    @Binding var stopAnimating:Bool
    var pct: Double
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
