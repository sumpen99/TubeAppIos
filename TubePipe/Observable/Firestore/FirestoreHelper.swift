//
//  FirestoreHelper.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-09-17.
//

import SwiftUI

extension FirestoreViewModel{
    
    func releaseAllData(){
        releaseContactSuggestions()
        releaseContactRequests()
        releaseCurrentUser()
    }
    
    func releaseCurrentUser(){
        currentUser = nil
    }
    
    func releaseContactMessages(){
        contactMessages.removeAll()
    }
    
    func releaseContactSuggestions(){
        contactSuggestions.removeAll()
    }
    
    func releaseContactRequests(){
        recievedContacts.removeAll()
        pendingContacts.removeAll()
        confirmedContacts.removeAll()
    }
    
    func closeAllListeners(){
        closeListenerContactRequests()
        closeListenerMessageGroups()
        closeListenerAppUser()
    }
    
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
    func closeListenerContactRequests(){
        listenerRequestRecieved?.remove()
        listenerRequestPending?.remove()
        listenerRequestConfirmed?.remove()
    }
    
    func closeListenerAppUser(){
        listenerAppUser?.remove()
    }
    
    func closeListenerMessageGroups(){
        listenerMessageGroups?.remove()
    }
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
    
    /*var possibleBadgeCount:Int{
        recievedContacts.count
    }*/
    
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
        return messageGroups[contactId] != nil
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

