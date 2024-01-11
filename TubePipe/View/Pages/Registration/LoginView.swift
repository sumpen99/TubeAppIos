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
    var isTimeOut:Bool = false
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
    
    var buttonIsDisabled:Bool{
        lVar.email.isEmpty||lVar.password.isEmpty||lVar.isTimeOut
    }
    
    var accountLabel:some View{
        Text("Accountinformation").font(.headline).hLeading().foregroundColor(.black)
    }
    
    var loginEmailTextfield:some View{
        VStack(spacing:5.0){
            HStack{
                Image(systemName: "mail")
                TextField("",text:$lVar.email)
                .preferedEmailField(textColor: Color.black)
                .placeholder(when: focusField != .LOGIN_EMAIL && lVar.email.isEmpty){ 
                    Text("email").foregroundColor(.black)
                }
                .focused($focusField,equals: .LOGIN_EMAIL)
                .hLeading()
            }
            .padding([.leading,.trailing])
            .background{
                Rectangle().stroke(lineWidth: 2.0).foregroundColor(Color.black)
            }
        }
    }
    
    var loginPasswordTextfield:some View{
        VStack(spacing:5.0){
            HStack{
                Image(systemName: "lock")
                SecureField("",text:$lVar.password)
                .preferedSecureField()
                .placeholder(when: focusField != .LOGIN_SECURE_PASSWORD && lVar.password.isEmpty){ Text("password").foregroundColor(.black)}
                .focused($focusField,equals: .LOGIN_SECURE_PASSWORD)
                .hLeading()
            }
            .padding([.leading,.trailing])
            .background{
                Rectangle().stroke(lineWidth: 2.0).foregroundColor(Color.black)
            }
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
        SpinnerButton(isTimeout: $lVar.isTimeOut, action: logUserIn, label: "Log In")
        .disabled(buttonIsDisabled)
        .buttonStyle(ButtonStyleDisabledable(lblColor: .white,
                                             borderColor: .black,
                                             backgroundColor: .systemBlue))
        .padding()
    }
    
    var loginFields:some View{
        VStack{
            loginLabel
            loginTextfields
            loginButton
        }
        .vTop()
    }
      
    var body: some View {
        AppBackgroundStack(content: {
            loginFields
        })
        .alert(isPresented: $lVar.isFailedLoginAttempt, content: {onResultAlert()})
        .hiddenBackButtonWithCustomTitle(color:Color.black)
   }
    
    func logUserIn(){
        if buttonIsDisabled{ return }
        lVar.isTimeOut = true
        firebaseAuth.loginWithEmail(lVar.email,password: lVar.password){ (result,error) in
            lVar.isTimeOut = false
            guard let nsError = error as NSError? else { return }
            toggleFailedLoginAttemptWithValue(nsError)
        }
    }
    
    func toggleFailedLoginAttemptWithValue(_ error:Error){
        ALERT_TITLE = "Login failed"
        ALERT_MESSAGE = error.localizedDescription
        lVar.isFailedLoginAttempt.toggle()
    }
    
}
