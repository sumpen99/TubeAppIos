//
//  SignupView.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-06-10.
//

import SwiftUI

struct SignupVariables{
    var timeOut:Bool = false
    var isFailedSignupAttempt:Bool = false
    var isMissingCredentials:Bool = false
    var passwordHelper = PasswordHelper()
    var errorMessage:String = ""
    
    var isTimeOut:Bool{ isFailedSignupAttempt || isMissingCredentials }
    var hideButton:Bool{
        (passwordHelper.passwordsIsAMatch == .NOT_ACCEPTED) || passwordHelper.emailText.isEmpty
    }
    
    var missingInfoMSG:String{
        if passwordHelper.emailText.isEmpty{ return "Missing email!"}
        return "Password dont match"
    }
}

struct SignupView : View {
    @EnvironmentObject var firebaseAuth: FirebaseAuth
    @FocusState var focusField: Field?
    @State var sVar = SignupVariables()
    
    var errorMessage:some View{
        ZStack{
            illegalCredentials
            missingInfo
        }
        .hCenter()
        .font(.callout)
        .foregroundColor(Color.systemRed)
        .listRowBackground(Color.clear)
    }
    
    var buttonIsDisabled:Bool{
        sVar.hideButton
    }
    
    var illegalCredentials:some View{
        Text(sVar.errorMessage)
        .opacity(sVar.isFailedSignupAttempt ? 1.0 : 0.0)
    }
    
    var missingInfo:some View{
        Text(sVar.missingInfoMSG)
        .opacity(sVar.isMissingCredentials ? 1.0 : 0.0)
    }
    
    var signupLabel:some View{
        VStack{
            Text("Registration").font(.largeTitle).bold().hLeading()
            Text("It`s free & and always will be!").font(.body).hLeading()
            
        }
        .foregroundColor(Color.black)
        .padding()
    }
    
    var accountLabel:some View{
        Text("Accountinformation").font(.headline).hLeading().foregroundColor(Color.black)
    }
    
    var signupEmailTextfield:some View{
        HStack{
            Image(systemName: "mail")
            TextField("",text:$sVar.passwordHelper.emailText)
                .preferedEmailField(textColor: Color.black)
                .placeholder(when: focusField != .SIGNUP_EMAIL && sVar.passwordHelper.emailText.isEmpty){
                    Text("email").foregroundColor(.black)
                }
                .focused($focusField,equals: .SIGNUP_EMAIL)
                .hLeading()
        }
        .padding([.leading,.trailing])
        .background{
            Rectangle().stroke(lineWidth: 2.0).foregroundColor(Color.black)
        }
    }
    
    var signupPasswordTextfield:some View{
        HStack{
            Image(systemName: sVar.passwordHelper.passwordsLevel != .NONE ? "lock" : "lock.open")
            SecureField("",text:$sVar.passwordHelper.password)
                .preferedSecureField()
                .placeholder(when: focusField != .SIGNUP_SECURE_PASSWORD && sVar.passwordHelper.password.isEmpty){
                    Text("password").foregroundColor(.black)
                }
                .focused($focusField,equals: .SIGNUP_SECURE_PASSWORD)
                .hLeading()
        }
        .padding([.leading,.trailing])
        .background{
            Rectangle().stroke(lineWidth: 2.0).foregroundColor(Color.black)
        }
        
    }
    
    var signupVerifyPasswordTextfield:some View{
        HStack{
            Image(systemName: sVar.passwordHelper.passwordsIsAMatch != .NOT_ACCEPTED ? "lock" : "lock.open")
            SecureField("",text:$sVar.passwordHelper.confirmedPassword)
                .preferedSecureField()
                .placeholder(when: focusField != .SIGNUP_RETYPE_SECURE_PASSWORD && sVar.passwordHelper.confirmedPassword.isEmpty){
                    Text("verify password").foregroundColor(.black)
                }
                .focused($focusField,equals: .SIGNUP_RETYPE_SECURE_PASSWORD)
                .hLeading()
        }
        .padding([.leading,.trailing])
        .background{
            Rectangle().stroke(lineWidth: 2.0).foregroundColor(Color.black)
        }
        
    }
    
    var emailSection:some View{
        Section {
            signupEmailTextfield
        } header: {
            Text("Accountinformation").listSectionHeader()
        } footer: {
            Text("No worries. Emails will not be sent to this adress nor will it be used in any other way. It`s whole purpose is to verify the account at TubePipe ").listSectionFooter()
        }.listRowBackground(Color.clear)
    }
    
    var passwordSection:some View{
        Section {
            signupPasswordTextfield
            signupVerifyPasswordTextfield
        } header: {
            Text("Password").listSectionHeader()
        } footer: {
            Text("Length of password need to be at least 6 digits.").listSectionFooter()
        }
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
    }
    
    var signupButton: some View{
        Button(action:signUserUp,label: {
            Text("Create account")
            .hCenter()
        })
        .disabled(buttonIsDisabled)
        .buttonStyle(ButtonStyleDisabledable(lblColor: .white,
                                             borderColor: .black,
                                             backgroundColor: .systemBlue))
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
    }
    
    var signupFields:some View{
        VStack(spacing:0){
            signupLabel
            List{
                emailSection
                passwordSection
                errorMessage
                signupButton
            }
            .scrollDisabled(true)
            .scrollContentBackground(.hidden)
        }
        .vTop()
    }
    
    var body: some View {
        AppBackgroundStack(content: {
            signupFields
            //.onSubmit { signUserUp() }
            //.submitLabel(.send)
        })
        .hiddenBackButtonWithCustomTitle(color:.black)
        .onTapGesture { endTextEditing() }
    }
    
    func signUserUp(){
        if buttonIsDisabled||sVar.timeOut { return }
        sVar.timeOut = true
        firebaseAuth.signupWithEmail(sVar.passwordHelper.emailText,
                                     password: sVar.passwordHelper.password){ (result,error) in
            guard let nsError = error as NSError? else { return }
            sVar.errorMessage = nsError.localizedDescription
            toggleFailedSignupAttemptWithValue(true)
        }
    }
    
    func toggleFailedSignupAttemptWithValue(_ value:Bool){
        withAnimation{
            sVar.isFailedSignupAttempt = value
        }
        if value{
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0){
                self.toggleFailedSignupAttemptWithValue(false)
                self.sVar.timeOut = false
            }
        }
    }
    
}
