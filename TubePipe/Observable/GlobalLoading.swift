//
//  GlobalLoading.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-10-07.
//

import SwiftUI

let ANIMATION_DURATION:CGFloat = 0.7
let SHOW_CHECKMARK_AFTER_ANIMATION:CGFloat = 1.5

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
    var loadingIsSuccess:Bool = true
    var messageAfterLoading:String = "Success"
  
    func startLoading(){
        withAnimation{
            loadingIsSuccess = true
            isLoading = true
        }
     }
    
    func stopLoading(isSuccess:Bool,message:String,showAnimationCircle:Bool){
        withAnimation{
            loadingIsSuccess = isSuccess
            messageAfterLoading = message
            isLoading = false
            if showAnimationCircle{
                show(content: .globalAutoFillProgressView)
            }
        }
    }
    
    func close(){
        loadingIsSuccess = true
        messageAfterLoading = ""
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

struct AnimatedRectangle:View{
    
    @State private var percentage: CGFloat = .zero
    var body:some View{
        Rectangle()
        .trim(from: percentage/2.0,to: percentage)
        .stroke(Color.green, lineWidth: 2.0)
        .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses:true), value: percentage)
        .frame(height: 1)
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
        splitLine.overlay{
            AnimatedRectangle()
        }
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
    @EnvironmentObject var globalLoadingPresentation: GlobalLoadingPresentation
    var body: some View {
        GeometryReader{ reader in
            let scale = min(reader.size.width,reader.size.height) / 4.0
            let width = min(scale*2.5,250.0)
            let rad = scale / 6.0
            ZStack{
                Color.white
            }
            .allowsHitTesting(false)
            .overlay{
                GlobalRingSpinner(size:scale)
            }
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
    
    var animatedCircle:some View{
        ZStack {
            Circle()
                .trim(from: 0.0, to: 1.0)
                .stroke(style: StrokeStyle(lineWidth: LINE_WIDTH_ANIMATED, lineCap: .round, lineJoin: .round))
                .opacity(0.3)
                .foregroundColor(globalLoadingPresentation.loadingIsSuccess ? Color.green : Color.red)
                .rotationEffect(.degrees(90.0))
            GlobalInnerRing(stopAnimating: $stopAnimating,pct: pct)
            .stroke(globalLoadingPresentation.loadingIsSuccess ? Color.green : Color.red, lineWidth: LINE_WIDTH_ANIMATED)
            if stopAnimating{
                Image(systemName: globalLoadingPresentation.loadingIsSuccess ? "checkmark" : "exclamationmark.triangle")
                .resizable()
                .frame(width: size*0.3,height: size*0.3)
                .foregroundColor(globalLoadingPresentation.loadingIsSuccess ? Color.green : Color.red)
                
            }
        }
        .padding()
        .frame(width: size,height: size)
    }
    
    @ViewBuilder
    var message:some View{
        if stopAnimating{
            ScrollView{
                Text(globalLoadingPresentation.messageAfterLoading)
                .italic()
                .foregroundColor(globalLoadingPresentation.loadingIsSuccess ? Color.green : Color.red)
                .lineLimit(nil)
                .padding()
                .hLeading()
            }
        }
        
    }
    
    var body: some View {
        HStack{
            animatedCircle
            message
        }
        .contentShape(Rectangle())
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
