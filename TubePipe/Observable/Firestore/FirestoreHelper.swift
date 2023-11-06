//
//  FirestoreHelper.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-09-17.
//

import SwiftUI

extension FirestoreViewModel{
    
    var groupIds:[String]?{
        if let user = currentUser,
           let groupIds = user.groupIds{
           return Array(groupIds.values)
        }
        return nil
    }
    
    var possibleBadgeCount:Int{
        recievedContacts.count + pendingContacts.count
    }
      
    var isCurrentUserPublic: Bool{
        guard let user = currentUser,
              let mode = user.userMode else { return false }
        return mode.userIsPublic()
    }
    
    var currentUserEmail: String{
        currentUser?.email ?? ""
    }
    
    var currentUserDisplayName:String{
        currentUser?.displayName ?? ""
    }
    
    var currentUserID: String?{
        currentUser?.userId
    }
    
    func getGroupIdFromOtherUserId(_ userId:String?) -> String?{
        guard let userId = userId,
              let currentUser = currentUser else { return nil }
        return currentUser.groupIds?[userId]
    }
    
    func contactInMessageGroup(_ contactId:String?) -> Bool{
        guard let contactId = contactId else { return false}
        if let group = messageGroups[contactId]{
            return !group.isEmpty
        }
        return false
    }
    
    func getContactLastMessage(_ contactId:String?) -> [Message]?{
        guard let contactId = contactId else { return nil}
        return messageGroups[contactId]
    }
    
    func getLatestMessageDetail(_ contactId:String?,messageDetail:MessageDetail) -> Any?{
        guard let contactId = contactId else { return nil}
        if let message = messageGroups[contactId]?.first{
            switch messageDetail{
            case .MESSAGE_DATE: return message.date
            case .MESSAGE_IMAGE: return message.storageId
            case .MESSAGE_MESSAGE: return message.message
            case .MESSAGE_TUBE: return message.sharedTube
            }
        }
        return nil
    }
    
    func checkForExistingRequestConnection(_ userId:String,initial:String) -> RequestStatus{
        if recievedContacts[userId] != nil { return .RECIEVED_REQUEST}
        if pendingContacts[userId] != nil { return .PENDING_REQUEST}
        guard let contacts = confirmedContacts[initial],
              let _ = contacts.firstIndex(where: { $0.userId ?? "" == userId })
        else{ return .NO_REQUEST }
        return .CONFIRMED_REQUEST
    }
    
    func mySelfAsContactWithStatus(_ status:RequestStatus) -> Contact?{
        guard let user = currentUser,
              let userId = user.userId,
              let email = user.email,
              let displayName = user.displayName else { return nil }
        return Contact(userId: userId,email: email,displayName: displayName,status: status)
    }
    
    func mySelfAsContactWithGroupIdAndStatus(_ status:RequestStatus,groupId:String?) -> Contact?{
        guard let user = currentUser,
              let userId = user.userId,
              let email = user.email,
              let displayName = user.displayName,
              let groupId = groupId else { return nil }
        return Contact(userId: userId,
                       email: email,
                       displayName: displayName,
                       status: status,
                       groupId: groupId)
    }
    
    func otherUserAsContactWithStatus(_ status:RequestStatus,contact:Contact) -> Contact{
        return Contact(userId: contact.userId,
                       email: contact.email,
                       displayName: contact.displayName,
                       status: status,
                       groupId: contact.groupId)
    }
    
    func createNewAppUser() -> AppUser?{
        guard let userId = FirebaseAuth.userId,
              let userEmail = FirebaseAuth.userEmail else { return nil }
        return AppUser(userId: userId,
                       email: userEmail,
                       displayName:"",
                       userMode: .USER_HIDDEN)
    }
    
    func createNewMessageGroup(groupId:String,otherUserId:String) -> MessageGroup?{
        guard let currentUserId = currentUserID else{ return nil }
        return MessageGroup(groupId: groupId, userIds: [currentUserId,otherUserId], groupInitialized: Date())
    }
    
}

//MARK: -- RELEASE DATA
enum FirestoreData{
    case DATA_USER
    case DATA_CONTACT_REQUEST
    case DATA_CONTACT_SUGGESTION
    case DATA_CONTACT_MESSAGES
    case DATA_CONTACT_MESSAGE_GROUPS
}

extension FirestoreData{
    
    static func all() -> [FirestoreData]{
        return [.DATA_USER,
                .DATA_CONTACT_REQUEST,
                .DATA_CONTACT_SUGGESTION,
                .DATA_CONTACT_MESSAGES,
                .DATA_CONTACT_MESSAGE_GROUPS]
    }
    
    static func messages() -> [FirestoreData]{
        return [.DATA_CONTACT_MESSAGES,
                .DATA_CONTACT_MESSAGE_GROUPS]
    }
}

extension FirestoreViewModel{
    
    func releaseData(_ dataList:[FirestoreData]){
        for data in dataList{
            switch data{
            case .DATA_USER:                    releaseCurrentUser()
            case .DATA_CONTACT_REQUEST:         releaseContactRequests()
            case .DATA_CONTACT_SUGGESTION:      releaseContactSuggestions()
            case .DATA_CONTACT_MESSAGES:        releaseContactMessages()
            case .DATA_CONTACT_MESSAGE_GROUPS:  releaseContactMessageGroups()
            }
        }
    }
    
    func releaseCurrentUser(){
        currentUser = nil
    }
    
    func releaseContactRequests(){
        recievedContacts.removeAll()
        pendingContacts.removeAll()
        confirmedContacts.removeAll()
    }
    
    func releaseContactSuggestions(){
        contactSuggestions.removeAll()
    }
    
    func releaseContactMessages(){
        contactMessages.removeAll()
    }
    
    func releaseContactMessageGroups(){
        messageGroups.removeAll()
    }
}

//MARK: -- INITIALIZE LISTENER
extension FirestoreViewModel{
    func initializeListenerContactRequestsIfUserIsPublic(){
        if isCurrentUserPublic{
            releaseContactRequests()
            initializeListenerContactRequests()
        }
        else{
            releaseContactRequests()
            closeListenerContactRequests()
        }
    }
    
    func initializeListenerContactRequests(){
        guard let userId = FirebaseAuth.userId else { return }
        listenForRequestRecievedContacts(userId)
        listenForRequestPendingContacts(userId)
        listenForRequestConfirmedContacts(userId)
    }
}


//MARK: -- CLOSE LISTENERS
enum FirestoreListener{
    case LISTENER_USER
    case LISTENER_MESSAGES
    case LISTENER_MESSAGE_GROUPS
    case LISTENER_CONTACT_REQUESTS
}

extension FirestoreListener{
  
    static func all() -> [FirestoreListener]{
        return [.LISTENER_USER,
                .LISTENER_MESSAGES,
                .LISTENER_MESSAGE_GROUPS,
                .LISTENER_CONTACT_REQUESTS]
    }
    
    static func messages() -> [FirestoreListener]{
        return [.LISTENER_MESSAGES,
                .LISTENER_MESSAGE_GROUPS]
    }
}
extension FirestoreViewModel{
    func closeListeners(_ listenerList:[FirestoreListener]){
        for listener in listenerList{
            switch listener{
            case .LISTENER_USER:                closeListenerAppUser()
            case .LISTENER_MESSAGES:            closeListenerMessages()
            case .LISTENER_MESSAGE_GROUPS:      closeListenerMessageGroups()
            case .LISTENER_CONTACT_REQUESTS:    closeListenerContactRequests()
            }
        }
    }
    
    func closeListenerAppUser(){
        //listenerAppUser?.remove()
        listenerAppUser = nil
    }
    
    func closeListenerMessages(){
        //listenerMessages?.remove()
        listenerMessages = nil
    }
    
    func closeListenerMessageGroups(){
        //listenerMessageGroups?.remove()
        listenerMessageGroups = nil
    }
    
    func closeListenerContactRequests(){
        //listenerRequestPending?.remove()
        //listenerRequestRecieved?.remove()
        //listenerRequestConfirmed?.remove()
        listenerRequestPending = nil
        listenerRequestRecieved = nil
        listenerRequestConfirmed = nil
    }
}

