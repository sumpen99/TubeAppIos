//
//  LoginView.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-06-10.
//

import SwiftUI

struct LoginVariables{
    var isFailedLoginAttempt:Bool = false
    var email:String = "fredrik@heatia.se"
    var password:String = "st3lv1oo"
    var timeOut:Bool = false
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
        lVar.email.isEmpty||lVar.password.isEmpty
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
            illegalCredentials
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
            .disabled(buttonIsDisabled)
            .buttonStyle(ButtonStyleDisabledable(lblColor: .white,
                                                 borderColor: .black,
                                                 backgroundColor: .systemBlue))
        }
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
        .hiddenBackButtonWithCustomTitle(color:Color.black)
        .onTapGesture { endTextEditing() }
   }
    
    func logUserIn(){
        if buttonIsDisabled||lVar.timeOut{ return }
        lVar.timeOut = true
        firebaseAuth.loginWithEmail(lVar.email,password: lVar.password){ (result,error) in
            guard let _ = error else { return }
            toggleFailedLoginAttemptWithValue(true)
        }
    }
    
    func toggleFailedLoginAttemptWithValue(_ value:Bool){
        withAnimation{
            lVar.isFailedLoginAttempt = value
        }
        if value{
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0){
                self.lVar.timeOut = false
                self.toggleFailedLoginAttemptWithValue(false)
            }
        }
    }
    
}
