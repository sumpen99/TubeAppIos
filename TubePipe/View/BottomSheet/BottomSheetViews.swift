//
//  BottomSheetViews.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-08-21.
//

import SwiftUI

enum BottomSheetType{
    case WELCOME
    
    @ViewBuilder
    func view() -> some View {
        switch self {
        case .WELCOME:
            WelcomeBottomSheet()
        }
        
    }
}

struct BottomSheet<Accessory: View>: View {
    @Binding var isShowing: Bool
    var accessoryView: Accessory
    
    var body: some View {
        ZStack(alignment: .bottom) {
            if (isShowing) {
                Color.black
                    .opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        isShowing.toggle()
                    }
                accessoryView
                    .padding(.bottom, 42)
                    .transition(.move(edge: .bottom))
                    .background(
                        appButtonGradient
                    )
                    .cornerRadius(16, corners: [.topLeft, .topRight])
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        .ignoresSafeArea()
        .animation(.easeInOut, value: isShowing)
    }
}

struct WelcomeBottomSheet: View{
    @EnvironmentObject var firebaseAuth: FirebaseAuth
    var body: some View{
        VStack(alignment: .leading) {
            HStack {
                Text("Welcome to tubepipe")
                    .foregroundColor(.black.opacity(0.9))
                    .font(.system(size: 20, weight: .bold))
                
                Spacer()
            }
            .padding(.top, 16)
            .padding(.bottom, 4)
            
            Text("Enter the world of creating segmented tubes effortless.")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.black.opacity(0.7))
                .padding(.bottom, 24)
            
            NavigationLink(destination:LazyDestination(destination: {
                LoginView().environmentObject(firebaseAuth) })) {
                Text("I already have an account, log in").hCenter()
            }
            .buttonStyle(ButtonStyleSheet())
            NavigationLink(destination:LazyDestination(destination: {
                SignupView().environmentObject(firebaseAuth) })) {
                Text("Create account").hCenter()
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
        .padding(.horizontal, 16)
    }
    
    func proceedAsAnonymous(){
        firebaseAuth.loginAsAnonymous(){ (result,error) in
            guard let _ = error else { return }
            //activateFailedSignupAlert(error:error)
            
        }
    }
    
}
