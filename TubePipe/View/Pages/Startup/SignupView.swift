//
//  SignupView.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-06-10.
//

import SwiftUI

struct SignupVariables{
    var isFailedSignupAttempt:Bool = false
    var orientation = UIDeviceOrientation.unknown
    var passwordHelper = PasswordHelper()
    var errorMessage:String = ""
    
    var hideButton:Bool{
        (passwordHelper.passwordsIsAMatch == .NOT_ACCEPTED) || passwordHelper.emailText.isEmpty
    }
}

struct SignupView : View {
    @EnvironmentObject var firebaseAuth: FirebaseAuth
    @FocusState var focusField: Field?
    @State var sVar = SignupVariables()
    var backButtonColor:Color = Color.white
    
    var illegalCredentials:some View{
        Text(sVar.errorMessage)
            .font(.callout)
            .hLeading()
            .foregroundColor(Color.systemRed)
            .opacity(sVar.isFailedSignupAttempt ? 1.0 : 0.0)
    }
    
    var signupLabel:some View{
        VStack{
            Text("Registration").font(.largeTitle).bold().hLeading()
            Text("It`s free & and always will be!").font(.body).hLeading()
            
        }
        .foregroundColor(Color.GHOSTWHITE)
        .padding()
    }
    
    var accountLabel:some View{
        Text("Accountinformation").font(.headline).hLeading().foregroundColor(Color.systemGray)
    }
    
    var signupEmailTextfield:some View{
        VStack(spacing:5.0){
            HStack{
                Image(systemName: "mail")
                TextField("",text:$sVar.passwordHelper.emailText,onCommit: { })
                    .preferedEmailField(textColor: Color.black)
                    .placeholder(when: focusField != .SIGNUP_EMAIL && sVar.passwordHelper.emailText.isEmpty){
                        Text("email").foregroundColor(.darkGray)
                    }
                    .focused($focusField,equals: .SIGNUP_EMAIL)
                    .hLeading()
            }
            .padding([.leading,.trailing])
            .background{
                Rectangle().fill(Color.white)
            }
            illegalCredentials
        }
        
    }
    
    var signupPasswordTextfield:some View{
        VStack(spacing:5.0){
            HStack{
                Image(systemName: sVar.passwordHelper.passwordsLevel != .NONE ? "lock" : "lock.open")
                SecureField("",text:$sVar.passwordHelper.password,onCommit: { })
                    .preferedSecureField()
                    .placeholder(when: focusField != .SIGNUP_SECURE_PASSWORD && sVar.passwordHelper.password.isEmpty){
                        Text("password").foregroundColor(.darkGray)
                    }
                    .focused($focusField,equals: .SIGNUP_SECURE_PASSWORD)
                    .hLeading()
            }
            .padding([.leading,.trailing])
            .background{
                Rectangle().fill(Color.white)
            }
         }
        
    }
    
    var signupVerifyPasswordTextfield:some View{
        VStack(spacing:5.0){
            HStack{
                Image(systemName: sVar.passwordHelper.passwordsIsAMatch != .NOT_ACCEPTED ? "lock" : "lock.open")
                SecureField("",text:$sVar.passwordHelper.confirmedPassword,onCommit: { })
                    .preferedSecureField()
                    .placeholder(when: focusField != .SIGNUP_RETYPE_SECURE_PASSWORD && sVar.passwordHelper.confirmedPassword.isEmpty){
                        Text("verify password").foregroundColor(.darkGray)
                    }
                    .focused($focusField,equals: .SIGNUP_RETYPE_SECURE_PASSWORD)
                    .hLeading()
            }
            .padding([.leading,.trailing])
            .background{
                Rectangle().fill(Color.white)
            }
        }
        
    }
    
    var signupTextfields: some View{
        VStack(spacing:10){
            accountLabel
            signupEmailTextfield
            signupPasswordTextfield
            signupVerifyPasswordTextfield
        }
        .padding()
    }
    
    var signupButton: some View{
        HStack{
            Button(action:signUserUp,label: {
                Text("Create account")
                .opacity(sVar.hideButton ? 0.5 : 1.0)
                .hCenter()
            })
            .buttonStyle(ButtonStyleDisabledable(lblColor: Color.white,
                                                 backgroundColor: Color.backgroundPrimary))
            //.disabled(sVar.hideButton)
        }
        .padding()
    }
    
    var signupFields:some View{
        ScrollView{
            VStack{
                signupLabel
                signupTextfields
                signupButton
            }
        }
    }
    
    var mainPage: some View{
        signupFields
        .vTop()
    }
    
    
    var body: some View {
        AppBackgroundStack(content: {
            mainPage
        })
        .hiddenBackButtonWithCustomTitle(color:backButtonColor)
        .onAppear{
            focusField = .SIGNUP_EMAIL
        }
        .modifier(NavigationViewModifier(title: ""))
    }
    
    func signUserUp(){
        if sVar.hideButton{ return }
        toggleFailedSignupAttemptWithValue(false)
        firebaseAuth.signupWithEmail(sVar.passwordHelper.emailText,
                                     password: sVar.passwordHelper.password){ (result,error) in
            guard let nsError = error as NSError? else {
                return
            }
            //FirebaseAuth.readNSError(nsError)
            sVar.errorMessage = nsError.localizedDescription
            toggleFailedSignupAttemptWithValue(true)
        }
    }
    
    func toggleFailedSignupAttemptWithValue(_ value:Bool){
        withAnimation{
            sVar.isFailedSignupAttempt = value
        }
    }
    
}
