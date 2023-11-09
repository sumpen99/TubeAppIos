//
//  FirestoreListener.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-09-17.
//

import SwiftUI
import OrderedCollections


extension FirestoreViewModel{
    func listenForCurrentUser(){
        guard let userId = FirebaseAuth.userId else { return; }
        let doc = repo.userDocument(userId)
        let listenerAppUser = doc.addSnapshotListener{ [weak self] snapshot, error in
            guard let strongSelf = self else { return }
            guard let changes = snapshot else { return }
            do {
                let user  = try changes.data(as: AppUser.self)
                strongSelf.currentUser = user
                strongSelf.initializeListenerContactRequestsIfUserIsPublic()
            }
            catch {
                debugLog(object: error.localizedDescription)
            }
        }
        self.listenerContainer[FirestoreListener.LISTENER_USER.rawValue] = listenerAppUser
    }
    
    func listenForRequestRecievedContacts(_ userId:String){
        let col = repo.requestRecievedCollection(userId)
        let listenerRequestRecieved = col.addSnapshotListener(){ [weak self] (snapshot, err) in
            guard let documents = snapshot?.documents,
                  let strongSelf = self else { return }
            var newContacts:OrderedDictionary<USERID,Contact> = [:]
            for document in documents {
                guard let contact = try? document.data(as : Contact.self),
                      let userId = contact.userId else { continue }
                newContacts[userId] = contact
            }
            strongSelf.recievedContacts = newContacts
        }
        self.listenerContainer[FirestoreListener.LISTENER_CONTACT_REQUESTS_RECIEVED.rawValue] = listenerRequestRecieved
        
    }
    func listenForRequestPendingContacts(_ userId:String){
        let col = repo.requestPendingCollection(userId)
        let listenerRequestPending = col.addSnapshotListener(){ [weak self] (snapshot, err) in
            guard let documents = snapshot?.documents,
                  let strongSelf = self else { return }
            var newContacts:OrderedDictionary<USERID,Contact> = [:]
            for document in documents {
                guard let contact = try? document.data(as : Contact.self),
                      let userId = contact.userId else { continue }
                newContacts[userId] = contact
            }
            strongSelf.pendingContacts = newContacts
        }
        self.listenerContainer[FirestoreListener.LISTENER_CONTACT_REQUESTS_PENDING.rawValue] = listenerRequestPending
        
    }
    
    func listenForRequestConfirmedContacts(_ userId:String){
        let col = repo.requestConfirmedCollection(userId)
        let listenerRequestConfirmed = col.addSnapshotListener(){ [weak self] (snapshot, err) in
            guard let documents = snapshot?.documents,
                  let strongSelf = self else { return }
            var newContacts:OrderedDictionary<INITIAL,[Contact]> = [:]
            for document in documents {
                guard let contact = try? document.data(as : Contact.self) else { continue }
                let initial = contact.initial
                guard let _ = newContacts["\(initial)"] else{
                    newContacts["\(initial)"] = [contact]
                    continue
                }
                newContacts["\(initial)"]?.append(contact)
            }
            strongSelf.confirmedContacts = newContacts
        }
        self.listenerContainer[FirestoreListener.LISTENER_CONTACT_REQUESTS_CONFIRMED.rawValue] = listenerRequestConfirmed
    }
    
    func listenForMessageGroups(){
         if let groupIds = groupIds{
            let col = repo.messageGroupCollection
            let listenerMessageGroups = col.whereField("groupId", in: groupIds).addSnapshotListener(){ [weak self] (snapshot, err) in
                guard let documents = snapshot?.documents,
                      let strongSelf = self else { return }
                for document in documents {
                    guard let group = try? document.data(as : MessageGroup.self),
                          let groupId = group.groupId
                    else{ continue }
                    strongSelf.getThreadDocumentsFromGroup(groupId)
                }
            }
            //self.closeListener(FirestoreListener.LISTENER_MESSAGE_GROUPS)
            self.listenerContainer[FirestoreListener.LISTENER_MESSAGE_GROUPS.rawValue] = listenerMessageGroups
        }
    }
    
    func listenForThreadDocumentsFromContact(groupId:String?){
         if let groupId = groupId{
            let col = repo.messageGroupThreadCollection(groupId)
            let listenerMessages = col.order(by: "date",descending: false).addSnapshotListener{ [weak self] (snapshot, error) in
                guard let documents = snapshot?.documents,
                      let strongSelf = self else{ return }
                var newMessages:[Message] = []
                for document in documents{
                    guard let message = try? document.data(as : Message.self)
                    else{ continue }
                    newMessages.append(message)
                }
                strongSelf.contactMessages = newMessages
            }
            self.closeListener(FirestoreListener.LISTENER_MESSAGES)
            self.listenerContainer[FirestoreListener.LISTENER_MESSAGES.rawValue] = listenerMessages
        }
        
    }
    
}
