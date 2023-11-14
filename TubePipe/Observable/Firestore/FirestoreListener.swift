//
//  FirestoreListener.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-09-17.
//

import SwiftUI
import OrderedCollections
import Firebase

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
        self.addNewListener(listenerAppUser,type:FirestoreListener.LISTENER_USER)
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
        self.addNewListener(listenerRequestRecieved,type:FirestoreListener.LISTENER_CONTACT_REQUESTS_RECIEVED)
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
        self.addNewListener(listenerRequestPending,type:FirestoreListener.LISTENER_CONTACT_REQUESTS_PENDING)
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
        self.addNewListener(listenerRequestConfirmed,type:FirestoreListener.LISTENER_CONTACT_REQUESTS_CONFIRMED)
    }
    
    func listenForMessageGroups(){
         if let groupIds = groupIds{
            let ref = repo.messageGroupCollection
            let col = ref.whereField("groupId", in: groupIds)
            let listenerMessageGroups = col.addSnapshotListener(){ [weak self] (snapshot, err) in
                guard let documents = snapshot?.documents,
                      let strongSelf = self else { return }
                for document in documents {
                    guard let group = try? document.data(as : MessageGroup.self),
                          let groupId = group.groupId
                    else{ continue }
                    strongSelf.getThreadDocumentsFromGroup(groupId)
                    /*if groupIds.contains(where: {$0 == groupId}){
                        strongSelf.getThreadDocumentsFromGroup(groupId)
                    }*/
                }
            }
            self.addNewListener(listenerMessageGroups,type:FirestoreListener.LISTENER_MESSAGE_GROUPS)
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
            self.addNewListener(listenerMessages,type:FirestoreListener.LISTENER_MESSAGES)
        }
        
    }
    
    private func addNewListener(_ listener:ListenerRegistration,type:FirestoreListener){
        closeListener(type)
        listenerContainer[type.rawValue] = listener
    }
    
}
