//
//  FirebaseAuth.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-06-10.
//

import SwiftUI
import FirebaseAuth
class FirebaseAuth:ObservableObject{
    let auth = Auth.auth()
    @Published private(set) var loggedInAs: UserRole = .NOT_LOGGED_IN
    private var handleAuthState: AuthStateDidChangeListenerHandle?
    static var currentUserEmail:String?
    static var currentUserId:String?
    
    init(){
        listenForAuthDidChange()
    }
    
    
    //MARK: - STATIC GETTER
    static var userId: String? { currentUserId }
    static var userEmail: String? { currentUserEmail }
    static func readNSError(_ err:NSError) -> String{
        guard let errorCode = AuthErrorCode.Code(rawValue: err.code) else {
            return "there was an error logging in but it could not be matched with a firebase code"
        }
        switch errorCode {
        case .emailAlreadyInUse: return "email already in use"
        case .invalidEmail: return "email badly formatted"
        default: return "undefined error"
        }
    }
        
    //MARK: - NOT STATIC GETTER
    var userEmail: String? { auth.currentUser?.email }
    
    var userID: String? { auth.currentUser?.uid }
    
    //MARK: - FUNCTIONS
    func listenForAuthDidChange() {
        guard handleAuthState == nil else { return }
        handleAuthState = auth.addStateDidChangeListener { [weak self] auth, _ in
            guard let strongSelf = self else { return }
            strongSelf.getUserRole(){ role in
                FirebaseAuth.currentUserId = auth.currentUser?.uid
                FirebaseAuth.currentUserEmail = auth.currentUser?.email
                DispatchQueue.main.async{
                    withAnimation{
                        strongSelf.loggedInAs = role
                    }
                }
                
            }
        }
    }
    
    func deleteAccount(email:String,password:String,onResult:((ResultOfOperation) -> Void)? = nil){
        var resultOfOperation = ResultOfOperation(presentedSucces: .ACCOUNT_DELETED)
        let eMailCredential = EmailAuthProvider.credential(withEmail: email, password: password)
        auth.currentUser?.reauthenticate(with: eMailCredential){ (authResult,errAuth) in
            resultOfOperation.add(errAuth)
            if let _ = errAuth { onResult?(resultOfOperation); return }
            authResult?.user.delete(){ errDelete in
                resultOfOperation.add(errDelete)
                onResult?(resultOfOperation)
            }
       }
    }
    
    func signOut(){
        do{
            try auth.signOut()
        }
        catch{
            debugLog(object:error)
        }
    }
    
    func getUserRole(completion: @escaping (UserRole) -> Void){
        guard let user = auth.currentUser else { completion(.NOT_LOGGED_IN); return }
        if user.isAnonymous { completion(.ANONYMOUS_USER); return;}
        user.getIDTokenResult(){ (result,error) in
            guard let role = result?.claims["role"] as? NSString else {
                completion(.REGISTERED_USER)
                return
            }
            if role == "admin"{ completion(.REGISTERED_USER) }
            else{ completion(.ANONYMOUS_USER) }
        }
    }
    
    func loginAsAnonymous(_ completion:((AuthDataResult?,Error?)->Void)?){
        auth.signInAnonymously(completion:completion)
    }
    
    func loginWithEmail(_ email:String,password:String,completion:((AuthDataResult?,Error?)->Void)?){
        auth.signIn(withEmail: email, password: password,completion:completion)
    }
    
    func signupWithEmail(_ email:String,password:String,completion:((AuthDataResult?,Error?)->Void)?){
        auth.createUser(withEmail: email, password: password,completion: completion)
    }
    
    func convertAnonymousWithEmail(_ email:String,password:String,completion:((AuthDataResult?,Error?)->Void)?){
        guard let authUser = auth.currentUser else { completion?(nil,FirebaseError.MISSING_USER_ID);return }
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        authUser.link(with: credential,completion:completion)
    }
    
    func deleteAnonymousUser(){
        auth.currentUser?.delete()
    }
}

