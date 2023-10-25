//
//  ProfileView.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-06-10.
//

import SwiftUI
import PhotosUI

enum ProfileHeader:String,CaseIterable{
    case PERSONAL = "Personal"
    case SOCIAL = "Share"
    case CONTACTS = "Contacts"
}

enum ActiveProfileSheet: Identifiable {
    case OPEN_CONTACTS
    case OPEN_INBOX
    var id: Int {
        hashValue
    }
}

enum ProfileAlertAction: Identifiable{
    case ALERT_LOGOUT
    case ALERT_MISSING_DISPLAYNAME
    case ALERT_MISSING_USERID
    
    var id: Int {
        hashValue
    }
    
    var rawValue:(title:String,message:String,cancel:String){
        switch self{
        case .ALERT_LOGOUT: return (title:"",message:"",cancel:"")
        case .ALERT_MISSING_DISPLAYNAME: return (title:"Missing username",message:"Please provide a valid username.",cancel:"Ok")
        case .ALERT_MISSING_USERID: return (title:"Unexpected error!",message:"Please try again.",cancel:"Ok")
        }
    }
}

struct ProfileVariables{
    var profileAlertAction: ProfileAlertAction?
    var activeProfileSheet: ActiveProfileSheet?
    var displayName: String = ""
    var isDeleteAccount:Bool = false
    
    mutating func updateUserVar(currentUser:AppUser?){
        guard let user = currentUser else { return }
        displayName = user.displayName ?? ""
    }
    
    func compareUserMode(currentUser:AppUser?,userSharing:Bool) -> Int{
        guard let user = currentUser else { return 0 }
        return ((user.userMode?.userIsPublic() ?? false) == userSharing) ? 0 : 1
    }
    
    func compareUserName(currentUser:AppUser?,allowEmpty:Bool) -> Int{
        guard let user = currentUser else { return 0 }
        if displayName.isEmpty && !allowEmpty { return 0}
        var changes:Int = 0
        changes += user.displayName.equalsOtherString(displayName) ? 0 : 1
        return changes
    }
    
    func compareUserVar(currentUser:AppUser?,userSharing:Bool) -> Bool{
        var changes:Int = 0
        changes += compareUserName(currentUser: currentUser,allowEmpty: false)
        changes += compareUserMode(currentUser: currentUser, userSharing: userSharing)
        return changes != 0
    }
}

struct ProfileView: View{
    @Namespace var animation
    @EnvironmentObject var tubeViewModel: TubeViewModel
    @EnvironmentObject var firestoreViewModel: FirestoreViewModel
    @EnvironmentObject var globalLoadingPresentation: GlobalLoadingPresentation
    @EnvironmentObject var firebaseAuth: FirebaseAuth
    @FocusState var focusField: Field?
    @State var pVar:ProfileVariables = ProfileVariables()
    @State var animateText:Bool = false
    
    var showPlaceholderText:Bool{
        (pVar.displayName.isEmpty && focusField != .PROFILE_DISPLAY_NAME)
    }
    
    var userHasAllowedSharing:Bool{
        firestoreViewModel.isCurrentUserPublic
    }
    
    var userAllowSharing:Bool{
        tubeViewModel.userDefaultSettingsVar.drawOptions[DrawOption.indexOf(op: .ALLOW_SHARING)]
    }
    
    var userModeHasChanged:Bool{
        pVar.compareUserMode(currentUser: firestoreViewModel.currentUser,
                             userSharing:tubeViewModel.userDefaultSettingsVar.drawOptions[DrawOption.indexOf(op: .ALLOW_SHARING)]) != 0
    }
    
    var userNameHasChanged:Bool{
        focusField == .PROFILE_DISPLAY_NAME
    }
    
    var changesHasHappend:Bool{
        pVar.compareUserVar(currentUser: firestoreViewModel.currentUser,
                            userSharing:tubeViewModel.userDefaultSettingsVar.drawOptions[DrawOption.indexOf(op: .ALLOW_SHARING)])
    }
    
    var tagContainer: [String] {
        let displayName = pVar.displayName.lowercased()
        var tag:[String] = [firestoreViewModel.currentUserEmail]
        if !displayName.isEmpty { tag.append(displayName) }
        return tag
    }
    
    @ViewBuilder
    var placeHolderText:some View{
        if userAllowSharing{
            BouncingText(isAnimating:$animateText,
                         text: " username",
                         color: .red)
        }
        else{
            Text(" username")
            .foregroundColor(.systemGray)
        }
    }
    
    var displayName:some View{
        HStack{
            TextField("",text:$pVar.displayName.max(MAX_TEXTFIELD_LEN))
            .preferedProfileSettingsField()
            .focused($focusField,equals: .PROFILE_DISPLAY_NAME)
            .placeholder(when: showPlaceholderText){
                placeHolderText
            }
        }
        .disabled(!userAllowSharing)
        .onChange(of: focusField,perform: replaceDisplaynameIfEmpty)
    }
        
    var userEmailtext:some View{
        Text(firestoreViewModel.currentUser?.email ?? "")
            .lineLimit(1)
            .hLeading()
            .listRowSeparator(.hidden)
    }
    
    var signoutButton:some View{
        Button(action: { pVar.profileAlertAction = .ALERT_LOGOUT }){
            HStack{
                Label("Sign out",systemImage: "arrow.right.square")
                .foregroundColor(.blue)
                .hLeading()
                Image(systemName: "chevron.right")
                .font(.footnote)
                .foregroundColor(.tertiaryLabel)
           }
        }
        .fullListWidthSeperator()
    }
    
    var deleteAccountButton:some View{
        Button(action: { pVar.isDeleteAccount.toggle() }){
            HStack{
                Label("Delete account",systemImage: "person.badge.minus")
                .foregroundColor(.red)
                .hLeading()
                Image(systemName: "chevron.right")
                .font(.footnote)
                .foregroundColor(.tertiaryLabel)
           }
        }
        .fullListWidthSeperator()
    }
    
    var togglePublicMode:some View{
        Toggle(isOn: self.$tubeViewModel.userDefaultSettingsVar.drawOptions[DrawOption.indexOf(op: .ALLOW_SHARING)]){
            Label("Public mode",systemImage: "globe").foregroundColor(.black)
        }
        .toggleStyle(CapsuleCheckboxStyle(alignLabelLeft: true))
        .fullListWidthSeperator()
    }
    
    var accountSection:some View{
        Section {
            userEmailtext
            displayName
        } header: {
            Text("Account").foregroundColor(.white).bold()
        }
    }
    
    var userSocialSection:some View{
        Section {
            togglePublicMode
            contactButton
            navigateToMessages
        } header: {
            Text("Social").foregroundColor(.white).bold()
        }
    }
    
    var supportSection:some View{
        Section {
            navigateToHelpCenter
            navigateToFileBug
        } header: {
            Text("Help & Support").foregroundColor(.white).bold()
        }
   }
    
    var privacySection:some View{
        Section {
            signoutButton
            deleteAccountButton
        } header: {
            Text("Privacy").foregroundColor(.white).bold()
        }
   }
    
    var personalPage:some View{
        List{
            accountSection
            userSocialSection
            supportSection
            privacySection
        }
        .listStyle(.insetGrouped)
    }
    
    var body: some View{
        NavigationView{
            AppBackgroundStack(content: {
                personalPage
            })
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { replaceDisplayName();endTextEditing(); }) {
                        Text("Clear")
                    }
                    .opacity(userNameHasChanged ? 1.0 : 0.0)
                    .disabled(!userNameHasChanged)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { saveChanges();endTextEditing(); }) {
                        Text("Save")
                    }
                    .opacity(changesHasHappend ? 1.0 : 0.0)
                    .disabled(!changesHasHappend)
                }
            }
            .modifier(NavigationViewModifier(title: ""))
        }
        .modifier(DeleteAccountModifier(isPresented: $pVar.isDeleteAccount,email: firestoreViewModel.currentUserEmail, onAction: deleteAccountAndAllData))
        .actionSheet(item: $pVar.profileAlertAction){ alert in
            switch alert{
            case .ALERT_LOGOUT: return actionSheetLogout
            case .ALERT_MISSING_DISPLAYNAME: return actionSheetWithCancel(alert.rawValue)
            case .ALERT_MISSING_USERID: return actionSheetWithCancel(alert.rawValue)
            }
        }
        .onAppear(){
            pVar.updateUserVar(currentUser: firestoreViewModel.currentUser)
            tubeViewModel.userDefaultSettingsVar.drawOptions[DrawOption.indexOf(op: .ALLOW_SHARING)] = firestoreViewModel.isCurrentUserPublic
        }
    }
    
    func replaceDisplayName(){
        pVar.displayName = firestoreViewModel.currentUserDisplayName
    }
    
    func replaceDisplaynameIfEmpty(_ field:Field?){
        if field != .PROFILE_DISPLAY_NAME && pVar.displayName.isEmpty{
            pVar.displayName = firestoreViewModel.currentUserDisplayName
        }
    }
    
    //MARK: NAVIGATIONBUTTONS
    var contactButton: some View{
        NavigationLink(destination:LazyDestination(destination: {
            ContactView()
         })){
            Label("Contacts",systemImage: "person.2").foregroundColor(.black)
        }
        .fullListWidthSeperator()
        .disabled(!userHasAllowedSharing)
    }
    
    var navigateToMessages:some View{
        NavigationLink(destination:LazyDestination(destination: {
            InboxContactMessages()
        })){
            Label("Messages", systemImage: "tray").foregroundColor(.black)
        }
        .disabled(!userHasAllowedSharing)
    }
    
    var navigateToFileBug:some View{
        NavigationLink(destination:LazyDestination(destination: {
            IssueView()
        })){
            Label("Report an issue",systemImage: "exclamationmark.triangle").foregroundColor(.black)
        }
        .fullListWidthSeperator()
    }
    
    //lifepreserver
    var navigateToHelpCenter:some View{
        NavigationLink(destination:LazyDestination(destination: {
            FeatureView()
        })){
            Label("Request a new feature",systemImage: "lightbulb").foregroundColor(.black)
            .buttonStyle(ButtonStyleFillListRow(lblColor: Color.systemRed))
        }
        .fullListWidthSeperator()
    }
    
    //MARK: ACTIONSHEET
    var actionSheetLogout:ActionSheet{
        ActionSheet(title: Text("Sign out"), message: Text("Do you want to sign out from your device or did the wrong button accidentally get pressed?"), buttons: [
            .destructive(Text("Yepp, sign me out!")) { signOut() },
            .cancel(Text("Cancel please"))
        ])
    }
    
}

//MARK: SAVE CHANGES TO USER
extension ProfileView{
    
    func saveChanges(){
        guard let userId = firestoreViewModel.currentUser?.userId
        else { pVar.profileAlertAction = .ALERT_MISSING_USERID; return }
        saveChangesPart1(userId: userId)
    }
    
    func saveChangesPart1(userId:String){
        if pVar.displayName.isEmpty { pVar.profileAlertAction = .ALERT_MISSING_DISPLAYNAME; return }
        saveChangesPart2(userId: userId)
    }
    
    func saveChangesPart2(userId:String){
        let allowSharing = tubeViewModel.userDefaultSettingsVar.drawOptions[DrawOption.indexOf(op: .ALLOW_SHARING)]
        let newUserModeString = UserMode.boolToUserModeString(allowSharing)
        
        let contact = Contact(userId:userId,
                              email:firestoreViewModel.currentUserEmail,
                              displayName:pVar.displayName,
                              tag: tagContainer)
        
        saveChangesPart3(contact: contact,
                         userId: userId,
                         allowSharing: allowSharing,
                         newUserModeStr: newUserModeString)
        
    }
    
    func saveChangesPart3(contact:Contact,
                          userId:String,
                          allowSharing:Bool,
                          newUserModeStr:String){
        globalLoadingPresentation.startLoading()
        firestoreViewModel.saveUpdatedUserMode(contact:contact,
                                               userId: userId,
                                               displayName: pVar.displayName,
                                               allowSharing: allowSharing,
                                               userModeHasChanged: userModeHasChanged,
                                               newUserModeStr: newUserModeStr,
                                               tagContainer: tagContainer){ result in
            if result.isSuccess && userModeHasChanged{
                tubeViewModel.saveUserDefaultDrawingValues()
            }
            globalLoadingPresentation.stopLoading(isSuccess:result.isSuccess,
                                                  message: result.message,
                                                  showAnimationCircle: true)
        }
    }
    
}

//MARK: REMOVE ACCOUNT
extension ProfileView{
    
    func deleteAccountAndAllData(email:String,password:String){
        firebaseAuth.deleteAccount(email: email, password: password){ result in
            if result.isSuccess{ deleteAccountAndAllDataPart2() }
        }
    }
    
    func deleteAccountAndAllDataPart2(){
        firestoreViewModel.closeAllListeners()
        PersistenceController.deleteAllData()
        firestoreViewModel.deleteAccount(){ result in
            firestoreViewModel.releaseAllData()
            signOut()
        }
        
    }
    
    func signOut(){
        firebaseAuth.signOut()
    }
}
