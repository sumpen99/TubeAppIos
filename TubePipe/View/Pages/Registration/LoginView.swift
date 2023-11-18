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
    
    var illegalCredentials:some View{
        Text("Username or password is incorrect")
            .font(.callout)
            .hLeading()
            .foregroundColor(Color.systemRed)
            .opacity(lVar.isFailedLoginAttempt ? 1.0 : 0.0)
    }
    
    var loginLabel:some View{
        VStack{
            Text("Oh Wow!").font(.largeTitle).bold().hLeading()
            Text("Happy to see you back, member!").font(.body).hLeading()
            
        }
        .foregroundColor(.black)
        .padding()
    }
    
    var accountLabel:some View{
        Text("Accountinformation").font(.headline).hLeading().foregroundColor(.black)
    }
    
    var loginEmailTextfield:some View{
        VStack(spacing:5.0){
            HStack{
                Image(systemName: "mail")
                TextField("",text:$lVar.email,onCommit: { })
                .preferedEmailField(textColor: Color.black)
                .placeholder(when: focusField != .LOGIN_EMAIL && lVar.email.isEmpty){ 
                    Text("email").foregroundColor(.darkGray)
                }
                .focused($focusField,equals: .LOGIN_EMAIL)
                .hLeading()
            }
            .padding([.leading,.trailing])
            .background{
                Rectangle().stroke(lineWidth: 2.0).foregroundColor(Color.black)
            }
            illegalCredentials
        }
        
    }
    
    var loginPasswordTextfield:some View{
        VStack(spacing:5.0){
            HStack{
                Image(systemName: "lock")
                SecureField("",text:$lVar.password,onCommit: { })
                .preferedSecureField()
                .placeholder(when: focusField != .LOGIN_SECURE_PASSWORD && lVar.password.isEmpty){ Text("password").foregroundColor(.darkGray)}
                .focused($focusField,equals: .LOGIN_SECURE_PASSWORD)
                .hLeading()
            }
            .padding([.leading,.trailing])
            .background{
                Rectangle().stroke(lineWidth: 2.0).foregroundColor(Color.black)
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
            .buttonStyle(ButtonStyleDocument(color: Color.backgroundButton))
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
      
    var body: some View {
        AppBackgroundStack(content: {
            loginFields
        })
        .hiddenBackButtonWithCustomTitle(color:Color.black)
        .onAppear{
            focusField = .LOGIN_EMAIL
        }
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
