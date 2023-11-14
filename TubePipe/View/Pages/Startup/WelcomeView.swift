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
}

struct WelcomeView : View {
    @EnvironmentObject var firebaseAuth: FirebaseAuth
    @State var wVar = WelcomVariables()
    
    var appLogoImage:some View{
        Image("tp5")
          .resizable()
          .padding()
          .aspectRatio(contentMode: .fit)
    }
    
    var welcomeButton: some View{
        HStack{
            Button(action:{ wVar.userPressedNext.toggle() },label: {
                HStack(){
                    Text("Enter").font(.largeTitle)
                }
                .hCenter()
                
            })
            .buttonStyle(ButtonStyleSheet())
        }
        .padding()
    }
    
    var body: some View {
        AppBackgroundStackWithoutBottomPadding(content: {
            appLogoImage
            welcomeButton.vBottom()
            dialog
        })
        .alert(isPresented: $wVar.isSignupResult, content: {
            onResultAlert()
        })
    }
    
    var dialog: some View {
        ZStack(alignment: .bottom) {
            if (wVar.userPressedNext) {
                Color.black
                    .opacity(0.3)
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
            Color.APP_MID_BACKGROUND_COLOR
            //appButtonGradient
       )
       .cornerRadius(16, corners: [.topLeft, .topRight])
   }
    
    var dialogText: some View{
        VStack{
            HStack {
                Text("Welcome to tubepipe")
                    .foregroundColor(.WHITESMOKE)
                    .font(.system(size: 20, weight: .bold))
                
                Spacer()
            }
            .padding(.top, 16)
            .padding(.bottom, 4)
            
            Text("Enter the world of creating segmented tubes effortless.")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.GHOSTWHITE)
                .padding(.bottom, 24)
        }
        
    }
    
    var dialogButtons: some View{
        VStack{
            NavigationLink(destination:LazyDestination(destination: {
                LoginView()
            })){
                Text("I already have an account, log in")
                .hCenter()
            }
            .buttonStyle(ButtonStyleSheet())
            NavigationLink(destination:LazyDestination(destination: {
                SignupView()
            })){
                Text("Create account")
                .hCenter()
            }
            .buttonStyle(ButtonStyleSheet())
            Button(action: proceedAsAnonymous ,label: {
                HStack(){
                    Text("Proceed as guest")
                }
                .hCenter()
            })
            .buttonStyle(ButtonStyleSheet())
        }
    }
    
   func proceedAsAnonymous(){
       firebaseAuth.loginAsAnonymous(){ (result,error) in
           guard let error = error else { return }
           activateFailedSiginAnonymousAlert(error:error)
           
       }
   }
    
    func activateFailedSiginAnonymousAlert(error:Error){
        ALERT_TITLE = "Login failed"
        ALERT_MESSAGE = error.localizedDescription
        wVar.isSignupResult.toggle()
    }
    
}

