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

enum ProfileRoute: Identifiable{
    case ROUTE_ISSUE
    case ROUTE_INFO
    case ROUTE_FEATURE
    case ROUTE_CONTACTS
    case ROUTE_MESSAGES
    case ROUTE_SETTINGS_TUBE
    
    var id: Int {
        hashValue
    }
    
}

enum ProfileAlertAction: Identifiable{
    case ALERT_LOGOUT
    case ALERT_MISSING_DISPLAYNAME
    case ALERT_DISPLAYNAME_ALREADY_TAKEN
    case ALERT_MISSING_USERID
    
    var id: Int {
        hashValue
    }
    
    var rawValue:(title:String,message:String,cancel:String){
        switch self{
        case .ALERT_LOGOUT: return (title:"",message:"",cancel:"")
        case .ALERT_MISSING_DISPLAYNAME: return (title:"Missing username",message:"Please provide a valid username.",cancel:"Ok")
        case .ALERT_DISPLAYNAME_ALREADY_TAKEN: return (title:"Username already taken!",message:"Please try a different name.",cancel:"Ok")
        case .ALERT_MISSING_USERID: return (title:"Unexpected error!",message:"Please try again.",cancel:"Ok")
        }
    }
}

struct ProfileVariables{
    var profileAlertAction: ProfileAlertAction?
    var activeProfileSheet: ActiveProfileSheet?
    var displayName: String = ""
    var isDeleteAccount:Bool = false
    var isEditUsername:Bool = false
    
    var userNameText:String{
        displayName == "" ? "username" : displayName
    }
    
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
    @EnvironmentObject var navigationViewModel: NavigationViewModel
    @EnvironmentObject var globalLoadingPresentation: GlobalLoadingPresentation
    @EnvironmentObject var firebaseAuth: FirebaseAuth
    @FocusState var focusField: Field?
    @State var pVar:ProfileVariables = ProfileVariables()
    @State var animateText:Bool = false
    
    var buttonDisabled:Bool{
        !changesHasHappend||globalLoadingPresentation.isLoading
    }
    
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
    
    var usernameTextfield: some View{
        TextField("",text:$pVar.displayName.max(MAX_TEXTFIELD_LEN),onCommit: {
            if !changesHasHappend{
                pVar.isEditUsername.toggle()
            }
        })
        .preferedProfileSettingsField()
        .focused($focusField,equals: .PROFILE_DISPLAY_NAME)
        .placeholder(when: showPlaceholderText){
            placeHolderText
        }
        .foregroundColor(userAllowSharing ? .black : .darkGray)
        .hLeading()
        .disabled(!userAllowSharing)
        .onChange(of: focusField,perform: replaceDisplaynameIfEmpty)
    }
    
    var usernameText:some View{
        HStack{
            Text(pVar.userNameText).foregroundColor(.darkGray).italic().hLeading()
            Button(action: {
                pVar.isEditUsername.toggle()
                focusField = .PROFILE_DISPLAY_NAME
            }, label: {
                Image(systemName: "square.and.pencil")
            })
            .disabled(!userAllowSharing)
        }
    }
    
    @ViewBuilder
    var placeHolderText:some View{
        if userAllowSharing{
            Text(" username")
            .foregroundColor(.systemRed)
        }
        else{
            Text(" username")
            .foregroundColor(.systemGray)
        }
    }
    
    @ViewBuilder
    var displayName:some View{
        HStack{
            Text("Username: ")
            .lineLimit(1)
            .italic()
            .foregroundColor(.black)
            if pVar.isEditUsername{ usernameTextfield }
            else{ usernameText }
            
        }
        .profileListRow()
    }
        
    var userEmailtext:some View{
        HStack{
            Text("Email: ")
                .lineLimit(1)
                .italic()
                .foregroundColor(.black)
            Text(firestoreViewModel.currentUser?.email ?? "")
                .lineLimit(1)
                .hLeading()
                .italic()
                .foregroundColor(.darkGray)
        }
        .profileListRow()
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
        .profileListRow()
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
        .profileListRow()
    }
    
    var togglePublicMode:some View{
        Toggle(isOn: self.$tubeViewModel.userDefaultSettingsVar.drawOptions[DrawOption.indexOf(op: .ALLOW_SHARING)]){
            Label("Public mode",systemImage: "globe").foregroundColor(.black)
        }
        .toggleStyle(CapsuleCheckboxStyle(alignLabelLeft: true))
        .profileListRow()
    }
    
    var accountSection:some View{
        Section {
            displayName
            userEmailtext
        } header: {
            Text("Account").profileSectionHeader()
        }
    }
    
    var settingsSection:some View{
        Section {
            navigateToUserSettings
        } header: {
            Text("Settings").profileSectionHeader()
        }
    }
    
    var userSocialSection:some View{
        Section {
            togglePublicMode
            contactButton
            navigateToMessages
        } header: {
            Text("Social").profileSectionHeader()
        }footer:{
            if !userHasAllowedSharing{
                Text("Public mode need to be set in order to connect with friends.").listSectionFooter()
            }
        }
    }
    
    var supportSection:some View{
        Section {
            navigateToHelpCenter
            navigateToFileBug
        } header: {
            Text("Help & Support").profileSectionHeader()
        }
   }
    
    var privacySection:some View{
        Section {
            signoutButton
            deleteAccountButton
        } header: {
            Text("Privacy").profileSectionHeader()
        }
   }
    
    var personalPage:some View{
        List{
            accountSection
            userSocialSection
            settingsSection
            supportSection
            privacySection
        }
        .scrollContentBackground(.hidden)
        .background(Color.backgroundPrimary)
        .listStyle(.grouped)
    }
    
    var body: some View{
        NavigationStack(path:$navigationViewModel.pathTo){
            AppBackgroundStack(content: {
                personalPage
            },title:firestoreViewModel.currentUser?.displayName ?? "")
            .onChange(of: userHasAllowedSharing){ has in
                if has{ startListening() }
                else{ releaseListener() }
            }
            .navigationDestination(for: Contact.self){  contact in
                ContactMessagesView(contact: contact,backButtonLabel: "Messages")
            }
            .navigationDestination(for: ProfileRoute.self){  route in
                switch route{
                case .ROUTE_SETTINGS_TUBE:  UserSettingsView()
                case .ROUTE_MESSAGES:       InboxContactMessages()
                case .ROUTE_CONTACTS:       ContactView()
                case .ROUTE_FEATURE:        FeatureView()
                case .ROUTE_ISSUE:          IssueView()
                default:                    EmptyView()
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: dismissUserChanges ) {
                        Text("Dismiss").foregroundColor(.systemRed).bold().font(.headline)
                    }
                    .toolbarFontAndPadding()
                    .opacity(changesHasHappend ? 1.0 : 0.0)
                    .disabled(!changesHasHappend)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: saveUserChanges ) {
                        Text("Save").foregroundColor(.systemBlue).bold().font(.headline)
                    }
                    .toolbarFontAndPadding()
                    .opacity(changesHasHappend ? 1.0 : 0.0)
                    .disabled(!changesHasHappend)
                }
            }
        }
        .modifier(DeleteAccountModifier(isPresented: $pVar.isDeleteAccount,email: firestoreViewModel.currentUserEmail, onAction: deleteAccountAndAllData))
        .actionSheet(item: $pVar.profileAlertAction){ alert in
            switch alert{
            case .ALERT_LOGOUT:                         return actionSheetLogout
            case .ALERT_MISSING_DISPLAYNAME:            return actionSheetWithCancel(alert.rawValue)
            case .ALERT_DISPLAYNAME_ALREADY_TAKEN:      return actionSheetWithCancel(alert.rawValue)
            case .ALERT_MISSING_USERID:                 return actionSheetWithCancel(alert.rawValue)
            }
        }
        .onAppear{ setupCurrentUser() }
        .onDisappear{ releaseListener() }
    }
    
    //MARK: HELPER FUNCTIONS
    func setupCurrentUser(){
        updateLocalUserFromFirebase()
        setIfCurrentUserIsInPublicMode()
        startListening()
    }
    
    func updateLocalUserFromFirebase(){
        pVar.updateUserVar(currentUser: firestoreViewModel.currentUser)
    }
    
    func replaceDisplayName(){
        pVar.displayName = firestoreViewModel.currentUserDisplayName
    }
    
    func replacePublicMode(){
        tubeViewModel.userDefaultSettingsVar.drawOptions[DrawOption.indexOf(op: .ALLOW_SHARING)] = firestoreViewModel.isCurrentUserPublic
    }
    
    func replaceDisplaynameIfEmpty(_ field:Field?){
        if field != .PROFILE_DISPLAY_NAME && pVar.displayName.isEmpty{
            pVar.displayName = firestoreViewModel.currentUserDisplayName
        }
    }
    
    func saveUserChanges(){
        saveChanges()
        endTextEditing()
        pVar.isEditUsername.toggle()
    }
    
    func dismissUserChanges(){
        replaceDisplayName()
        replacePublicMode()
        endTextEditing()
        pVar.isEditUsername.toggle()
    }
    
    //MARK: NAVIGATIONBUTTONS
    var contactButton: some View{
        Button(action: { navigationViewModel.switchPathToRoute(ProfileRoute.ROUTE_CONTACTS)}, label: {
            buttonAsNavigationLink(title: "Contacts", systemImage: "smallcircle.circle")
        })
        .opacity(userHasAllowedSharing ? 1.0 : 0.3)
        .disabled(!userHasAllowedSharing)
        .profileListRow()
    }
    
    var navigateToUserSettings:some View{
        Button(action: { navigationViewModel.switchPathToRoute(ProfileRoute.ROUTE_SETTINGS_TUBE)}, label: {
            buttonAsNavigationLink(title: "Default Tube", systemImage: "smallcircle.circle")
        })
        .profileListRow()
    }
    
    var navigateToMessages:some View{
        Button(action: { navigationViewModel.switchPathToRoute(ProfileRoute.ROUTE_MESSAGES)},label: {
            buttonAsNavigationLink(title: "Messages", systemImage: "tray")
        })
        .opacity(userHasAllowedSharing ? 1.0 : 0.3)
        .disabled(!userHasAllowedSharing)
        .profileListRow()
    }
    
    var navigateToFileBug:some View{
        Button(action: { navigationViewModel.switchPathToRoute(ProfileRoute.ROUTE_ISSUE)}, label: {
            buttonAsNavigationLink(title: "Issue report", systemImage: "exclamationmark.triangle")
        })
        .profileListRow()
    }
    
    var navigateToHelpCenter:some View{
        Button(action: { navigationViewModel.switchPathToRoute(ProfileRoute.ROUTE_FEATURE)}, label: {
            buttonAsNavigationLink(title: "Feature request", systemImage: "lightbulb")
        })
        .profileListRow()
    }
    
    //MARK: ACTIONSHEET
    var actionSheetLogout:ActionSheet{
        ActionSheet(title: Text("Sign out"), message: Text("Do you want to sign out from your device or did the wrong button accidentally get pressed?"), buttons: [
            .default(Text("Yepp, sign me out!")) { signOut() },
            .destructive(Text("Cancel please"))
        ])
    }
    
}

//MARK: SAVE CHANGES TO USER
extension ProfileView{
    
    func saveChanges(){
        if buttonDisabled{ return }
        guard let userId = firestoreViewModel.currentUser?.userId
        else { pVar.profileAlertAction = .ALERT_MISSING_USERID; return }
        saveChangesPart1(userId: userId)
    }
    
    func saveChangesPart1(userId:String){
        if pVar.displayName.isEmpty { pVar.profileAlertAction = .ALERT_MISSING_DISPLAYNAME; return }
        saveChangesPart2(userId: userId)
    }
    
    func saveChangesPart2(userId:String){
        firestoreViewModel.isUsernameAlreadyPresent(userId,userName:pVar.displayName){ exists in
            if exists{ pVar.profileAlertAction = .ALERT_DISPLAYNAME_ALREADY_TAKEN; return }
            saveChangesPart3(userId: userId)
        }
    }
    
    func saveChangesPart3(userId:String){
        let allowSharing = tubeViewModel.userDefaultSettingsVar.drawOptions[DrawOption.indexOf(op: .ALLOW_SHARING)]
        let newUserModeString = UserMode.boolToUserModeString(allowSharing)
        
        let contact = Contact(userId:userId,
                              email:firestoreViewModel.currentUserEmail,
                              displayName:pVar.displayName,
                              tag: tagContainer)
        
        saveChangesPart4(contact: contact,
                         userId: userId,
                         allowSharing: allowSharing,
                         newUserModeStr: newUserModeString)
        
    }
    
    func saveChangesPart4(contact:Contact,
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

//MARK: TUBEVIEWMODEL FUNCTIONS
extension ProfileView{
    func setIfCurrentUserIsInPublicMode(){
        tubeViewModel.userDefaultSettingsVar.drawOptions[DrawOption.indexOf(op: .ALLOW_SHARING)] = firestoreViewModel.isCurrentUserPublic
    }
}

//MARK: FIRESTORE LISTENER FUNCTIONS
extension ProfileView{
    
    func startListening(){
        if userHasAllowedSharing{
            firestoreViewModel.initializeListenerContactRequests(FirestoreListener.contacts())
            firestoreViewModel.listenForMessageGroups()
        }
    }
    
    func releaseListener(){
        firestoreViewModel.closeListenerMessages()
        firestoreViewModel.closeListenerContactRequests()
        firestoreViewModel.releaseData([.DATA_CONTACT_MESSAGE_GROUPS,
                                        .DATA_CONTACT_MESSAGES,
                                        .DATA_CONTACT_REQUEST,
                                        .DATA_CONTACT_SUGGESTION])
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
        PersistenceController.deleteAllData()
        firestoreViewModel.deleteAccount(){ result in
            signOut()
        }
        
    }
    
    func releaseData(){
        firestoreViewModel.releaseData(FirestoreData.all())
        firestoreViewModel.closeListeners(FirestoreListener.all())
    }
    
    func signOut(){
        releaseData()
        firestoreViewModel.closeThisInstanceOfFirebase()
        firebaseAuth.signOut()
    }
}
