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
        GeometryReader{ reader in
            Image("tpIcon")
                .resizable()
                .frame(width: reader.size.width/2.0, height:reader.size.width/2.0)
              .hCenter()
              .vCenter()
              .padding()
        }
        
    }
    
    var welcomeButton: some View{
        Button(action:{ wVar.userPressedNext.toggle() },label: {
            HStack(){
                Text("Enter").font(.largeTitle)
            }
            .hCenter()
            
        })
        .buttonStyle(ButtonStyleDocument(color: Color.backgroundButton))
        .padding()
        .vBottom()
    }
    
    var body: some View {
        NavigationStack{
            AppBackgroundStackWithoutBottomPadding(content: {
                appLogoImage
                welcomeButton
                dialog
            })
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
                Text("Welcome to tubepipe")
                    .foregroundColor(.black)
                    .font(.system(size: 20, weight: .bold))
                
                Spacer()
            }
            .padding(.top, 16)
            .padding(.bottom, 4)
            
            Text("Enter the world of creating segmented tubes effortless.")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.black)
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
            .buttonStyle(ButtonStyleDocument(color: Color.systemGreen))
            NavigationLink(destination:LazyDestination(destination: {
                SignupView()
            })){
                Text("Create account")
                .hCenter()
            }
            .buttonStyle(ButtonStyleDocument(color: Color.systemBlue))
            Button(action: proceedAsAnonymous ,label: {
                HStack(){
                    Text("Proceed as guest")
                }
                .hCenter()
            })
            .buttonStyle(ButtonStyleDocument(color: Color.systemOrange))
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

