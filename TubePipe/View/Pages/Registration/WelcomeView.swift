//
//  WelcomeView.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-06-11.
//

import SwiftUI
  
struct WelcomVariables{
    var userPressedNext:Bool = false
    var isSignupResult:Bool = false
    var isAnonymousAttempt:Bool = false
    var isRotating:Bool = false
    
}

struct WelcomeView : View {
    @EnvironmentObject var firebaseAuth: FirebaseAuth
    @State var wVar = WelcomVariables()
   
    var appLogoImage:some View{
        GeometryReader{ reader in
            RotateImageView(isActive: $wVar.isRotating, name: "tpIcon3")
            .frame(width: reader.size.width/2,height: reader.size.width/2)
            .hCenter()
            .vCenter()
            .padding()
        }
    }
    
    var welcomeLabel:some View{
        Text("TubePipe")
        .underline(true)
        .font(.largeTitle)
        .bold()
        .foregroundColor(.black)
        .vTop()
        .hCenter()
    }
    
    var welcomeButton: some View{
        Button(action:{ wVar.userPressedNext.toggle();wVar.isRotating.toggle() },label: {
            Text("Enter").font(.largeTitle)
            .hCenter()
        })
        .buttonStyle(ButtonStyleSheet())
        .padding()
        .vBottom()
    }
    
    var body: some View {
        NavigationStack{
            AppBackgroundStackWithoutBottomPadding(content: {
                welcomeLabel
                appLogoImage
                welcomeButton
                dialog
            })
            .overlay{
                if wVar.isAnonymousAttempt{
                    ZStack{
                        Color.lightText
                    }
                }
            }
            .alert(isPresented: $wVar.isSignupResult, content: {
                onResultAlert()
            })
        }
    }
    
    var dialog: some View {
        ZStack(alignment: .bottom) {
            if (wVar.userPressedNext) {
                Color.white
                .opacity(0.1)
                .ignoresSafeArea()
                .onTapGesture {
                    wVar.userPressedNext.toggle()
                }
                dialogContent
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        .ignoresSafeArea()
        .animation(.easeInOut, value: wVar.userPressedNext)
    }
    
    var dialogContent: some View{
        VStack(alignment: .leading) {
            dialogText
            dialogButtons
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 42)
        .transition(.move(edge: .bottom))
        .background(
             Color.white
             .overlay(
                 RoundedRectangle(cornerRadius: 16)
                 .stroke(Color.black, lineWidth: 2)
             )
        )
        .cornerRadius(16, corners: [.topLeft, .topRight])
        .foregroundColor(.black)
   }
    
    var dialogText: some View{
        VStack{
            HStack {
                Text("Welcome to TubePipe")
                    .foregroundColor(.black)
                    .font(.system(size: 20, weight: .bold))
                
                Spacer()
            }
            .padding(.top, 16)
            .padding(.bottom, 4)
            
            Text("You are now one step away from entering the world of segmented pipes.")
                .hLeading()
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.black)
                .padding(.bottom, 24)
        }
        
    }
    
    var dialogButtons: some View{
        VStack{
            NavigationLink(destination:LazyDestination(destination: {
                SignupView(CONVERT_ANONYMOUS: false)
            })){
                buttonAsNavigationLink(title: "Ok! I would like to create an account",
                                       systemImage: "person.crop.circle.badge.plus",
                                       lblColor: .black,imgColor: .black)
            }
            .buttonStyle(ButtonStyleDocument(color: Color(hex: 0xDBA63F)))
            NavigationLink(destination:LazyDestination(destination: {
                LoginView()
            })){
                buttonAsNavigationLink(title: "I already have an account, log in",
                                       systemImage: "person.crop.circle.badge.checkmark",
                                       lblColor: .black,imgColor: .black)
            }
            .buttonStyle(ButtonStyleDocument(color: Color(hex: 0xF3BC54)))
            Button(action: proceedAsAnonymous ,label: {
                buttonAsNavigationLink(title: "Take a peek first? Enter as guest",
                                       systemImage: "person.crop.circle.badge.questionmark",
                                       lblColor: .black,imgColor: .black)
            })
            .buttonStyle(ButtonStyleDocument(color: Color(hex: 0xFFD26A)))
        }
    }
    
   func proceedAsAnonymous(){
       if wVar.isAnonymousAttempt{ return }
       wVar.isAnonymousAttempt = true
       firebaseAuth.loginAsAnonymous(){ (result,error) in
           guard let error = error else {
               wVar.isAnonymousAttempt = false
               return
           }
           activateFailedSiginAnonymousAlert(error:error)
           
       }
   }
    
    func activateFailedSiginAnonymousAlert(error:Error){
        ALERT_TITLE = "Login failed"
        ALERT_MESSAGE = error.localizedDescription
        wVar.isSignupResult.toggle()
        wVar.isAnonymousAttempt = false
    }
    
}

