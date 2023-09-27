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
        listenerAppUser = doc.addSnapshotListener{ [weak self] snapshot, error in
            guard let strongSelf = self else { return }
            guard let changes = snapshot else { return }
            do {
                let user  = try changes.data(as: AppUser.self)
                strongSelf.currentUser = user
                strongSelf.initializeListenerContactRequestsIfUserIsPublic()
                strongSelf.listenForMessageGroups()
            }
            catch {
                debugLog(object: error.localizedDescription)
            }
        }
    }
    
    func listenForRequestRecievedContacts(_ userId:String){
        let col = repo.requestRecievedCollection(userId)
        listenerRequestRecieved = col.addSnapshotListener(){ [weak self] (snapshot, err) in
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
        
    }
    func listenForRequestPendingContacts(_ userId:String){
        let col = repo.requestPendingCollection(userId)
        listenerRequestPending = col.addSnapshotListener(){ [weak self] (snapshot, err) in
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
        
    }
    
    func listenForRequestConfirmedContacts(_ userId:String){
        let col = repo.requestConfirmedCollection(userId)
        listenerRequestConfirmed = col.addSnapshotListener(){ [weak self] (snapshot, err) in
            guard let documents = snapshot?.documents,
                  let strongSelf = self else { return }
            var newContacts:OrderedDictionary<INITIAL,[Contact]> = [:]
            for document in documents {
                guard let contact = try? document.data(as : Contact.self) else { continue }
                let initial = contact.initial
                // If we have initial else set
                guard let _ = newContacts["\(initial)"] else{
                    newContacts["\(initial)"] = [contact]
                    continue
                }
                newContacts["\(initial)"]?.append(contact)
            }
            strongSelf.confirmedContacts = newContacts
        }
    }
    
    func listenForMessageGroups(){
        if let groupIds = groupIds{
            let col = repo.messageGroupCollection.whereField("groupId", in: groupIds)
            listenerMessageGroups = col.addSnapshotListener(){ [weak self] (snapshot, err) in
                guard let documents = snapshot?.documents,
                      let strongSelf = self else { return }
                for document in documents {
                    guard let group = try? document.data(as : MessageGroup.self),
                          let groupId = group.groupId
                    else{ continue }
                    strongSelf.getThreadDocumentsFromGroup(groupId)
                }
            }
        }
    }
    
}
