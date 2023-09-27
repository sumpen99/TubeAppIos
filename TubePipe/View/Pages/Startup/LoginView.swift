//
//  LoginView.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-06-10.
//

import SwiftUI

struct LoginVariables{
    var isFailedLoginAttempt:Bool = false
    var email:String = ""
    var password:String = ""
}

struct LoginView : View {
    @EnvironmentObject var firebaseAuth: FirebaseAuth
    @FocusState var focusField: Field?
    @State var lVar = LoginVariables()
    
    var loginLabel:some View{
        VStack{
            Text("Oh Wow!").font(.largeTitle).bold().hCenter()
            Text("Happy to see you back, member!").font(.body).hCenter()
            
        }
        .foregroundColor(Color.GHOSTWHITE)
        .padding()
    }
    
    var accountLabel:some View{
        Text("Accountinformation").font(.headline).hLeading().foregroundColor(Color.systemGray)
    }
    
    var illegalCredentials:some View{
        Text("Username or password is incorrect")
            .font(.callout)
            .hLeading()
            .foregroundColor(Color.systemRed)
            .opacity(lVar.isFailedLoginAttempt ? 1.0 : 0.0)
    }
    
    var loginEmailTextfield:some View{
        VStack(spacing:5.0){
            HStack{
                Image(systemName: "mail")
                TextField("",text:$lVar.email)
                    .preferedEmailField(textColor: Color.black)
                    .placeholder("email",when: lVar.email.isEmpty)
                    .focused($focusField,equals: .LOGIN_EMAIL)
                    .hLeading()
            }
            .padding([.leading,.trailing])
            .background{
                Rectangle().fill(Color.white)
            }
            .fieldFirstResponder {
                focusField = .LOGIN_EMAIL
            }
            illegalCredentials
        }
        
    }
    
    var loginPasswordTextfield:some View{
        VStack(spacing:5.0){
            HStack{
                Image(systemName: "lock")
                SecureField("",text:$lVar.password)
                    .preferedSecureField()
                    .placeholder("password",
                                 when: lVar.password.isEmpty)
                    .focused($focusField,equals: .LOGIN_SECURE_PASSWORD)
                    .hLeading()
            }
            .padding([.leading,.trailing])
            .background{
                Rectangle().fill(Color.white)
            }
            .fieldFirstResponder {
                focusField = .LOGIN_SECURE_PASSWORD
            }
            illegalCredentials
        }
        
    }
    
    var loginTextfields: some View{
        VStack(spacing:10){
            accountLabel
            loginEmailTextfield
            loginPasswordTextfield
        }
        .padding()
    }
    
   
    var loginButton: some View{
        HStack{
            Button(action:logUserIn,label: {
                Text("Log in").hCenter()
            })
            .buttonStyle(ButtonStyleSheet())
        }
        .padding()
    }
    
    var loginFields:some View{
        ScrollView{
            VStack{
                loginLabel
                loginTextfields
                loginButton
            }
        }
    }
    
    var mainPage: some View{
        loginFields
        .vTop()
    }
    
    var body: some View {
        AppBackgroundStack(content: {
            mainPage
        })
        .hiddenBackButtonWithCustomTitle(color:Color.white)
        .onAppear{
            focusField = .LOGIN_EMAIL
        }
        .modifier(NavigationViewModifier(title: ""))
   }
    
    func logUserIn(){
        toggleFailedLoginAttemptWithValue(false)
        firebaseAuth.loginWithEmail(lVar.email,password: lVar.password){ (result,error) in
            guard let _ = error else { return }
            toggleFailedLoginAttemptWithValue(true)
        }
    }
    
    func toggleFailedLoginAttemptWithValue(_ value:Bool){
        withAnimation{
            lVar.isFailedLoginAttempt = value
        }
    }
    
}
