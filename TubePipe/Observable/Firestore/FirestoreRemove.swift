//
//  FirestoreRemove.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-09-17.
//

import SwiftUI

extension FirestoreViewModel{
     func removeConnectionTo(_ otherUser: Contact,
                            onResult:((ResultOfOperation) -> Void)? = nil) {
        DispatchQueue.global(qos: .default).async {
            let dpGroup = DispatchGroup()
            var resultOfOperation = ResultOfOperation(presentedSucces: .CONTACT_REMOVED)
            dpGroup.enter()
            self.removeMyConnectionTo(otherUser){ err in
                resultOfOperation.add(err)
                dpGroup.leave()
            }
            dpGroup.enter()
            self.removeMyConnectionFrom(otherUser){ err in
                resultOfOperation.add(err)
                dpGroup.leave()
            }
            dpGroup.notify(queue: .main) {
                onResult?(resultOfOperation)
            }
        }
    }
    
    
    func removeContactRequestTo(_ otherUser: Contact,
                                onResult:((ResultOfOperation) -> Void)? = nil) {
        DispatchQueue.global(qos: .default).async {
            let dpGroup = DispatchGroup()
            var resultOfOperation = ResultOfOperation(presentedSucces: .CONTACT_REQUEST_REMOVED)
            dpGroup.enter()
            self.removeMyRequestFrom(otherUser){ err in
                resultOfOperation.add(err)
                dpGroup.leave()
            }
            dpGroup.enter()
            self.removeMyRequestedContact(otherUser){ err in
                resultOfOperation.add(err)
                dpGroup.leave()
            }
            dpGroup.enter()
            self.removeGroupIdFromUser(otherUserId: otherUser.userId){ err in
                resultOfOperation.add(err)
                dpGroup.leave()
            }
            dpGroup.notify(queue: .main) {
                onResult?(resultOfOperation)
            }
        }
    }
    
    func removeMyConnectionTo(_ otherUser: Contact,onResult:((Error?) -> Void)? = nil){
        guard let userId = FirebaseAuth.userId,
              let otherId = otherUser.userId else { onResult?(FirebaseError.MISSING_USER_ID);return; }
        let doc = repo.requestConfirmedDocument(userId,requestId: otherId)
        doc.delete(){ err in
            onResult?(err)
        }
    }
    
    func removeMyConnectionFrom(_ otherUser: Contact,onResult:((Error?) -> Void)? = nil){
        guard let userId = otherUser.userId,
              let myId = FirebaseAuth.userId else { onResult?(FirebaseError.MISSING_USER_ID);return; }
        let doc = repo.requestConfirmedDocument(userId,requestId: myId)
        doc.delete(){ err in
            onResult?(err)
        }
    }
    
    func removeMyRequestFrom(_ otherUser: Contact,onResult:((Error?) -> Void)? = nil){
        guard let userId = otherUser.userId,
              let myId = FirebaseAuth.userId else { onResult?(FirebaseError.MISSING_USER_ID);return; }
        let doc = repo.requestRecievedDocument(userId,requestId: myId)
        doc.delete(){ err in
            onResult?(err)
        }
    }
    
    func removeMyRequestedContact(_ otherUser: Contact,onResult:((Error?) -> Void)? = nil){
        guard let userId = otherUser.userId,
              let myId = FirebaseAuth.userId else { onResult?(FirebaseError.MISSING_USER_ID);return; }
        let doc = repo.requestPendingDocument(myId,requestId: userId)
        doc.delete(){ err in
            onResult?(err)
        }
    }
    
    func removeContactRequestFrom(_ otherUser: Contact,
                                  onResult:((ResultOfOperation) -> Void)? = nil) {
        DispatchQueue.global(qos: .default).async {
            let dpGroup = DispatchGroup()
            var resultOfOperation = ResultOfOperation(presentedSucces: .CONTACT_REQUEST_REMOVED)
            dpGroup.enter()
            self.removeRequestFrom(otherUser){ err in
                resultOfOperation.add(err)
                dpGroup.leave()
            }
            dpGroup.enter()
            self.removeMeFrom(otherUser){ err in
                resultOfOperation.add(err)
                dpGroup.leave()
            }
            dpGroup.notify(queue: .main) {
                onResult?(resultOfOperation)
            }
            
        }
    }
    
    
    func removeRequestFrom(_ otherUser: Contact,onResult:((Error?) -> Void)? = nil){
        guard let userId = otherUser.userId,
              let myId = FirebaseAuth.userId else { onResult?(FirebaseError.MISSING_USER_ID);return; }
        let doc = repo.requestRecievedDocument(myId,requestId: userId)
        doc.delete(){ err in
            onResult?(err)
        }
    }
    
    func removeMeFrom(_ otherUser: Contact,onResult:((Error?) -> Void)? = nil){
        guard let userId = otherUser.userId,
              let myId = FirebaseAuth.userId else { onResult?(FirebaseError.MISSING_USER_ID);return; }
        let doc = repo.requestPendingDocument(userId,requestId: myId)
        doc.delete(){ err in
            onResult?(err)
        }
    }
    
    func removeUserRequestDocument(onResult:((Error?) -> Void)? = nil){
        guard let userId = FirebaseAuth.userId else { onResult?(FirebaseError.MISSING_USER_ID);return; }
        let doc = repo.userRequestDocument(userId)
        doc.delete(){ err in
            onResult?(err)
        }
    }
    
    func removeUserDocument(onResult:((Error?) -> Void)? = nil){
        guard let userId = FirebaseAuth.userId else { onResult?(FirebaseError.MISSING_USER_ID);return; }
        let doc = repo.userDocument(userId)
        doc.delete(){ err in
            onResult?(err)
        }
    }
    
    func removeMessageFromGroup(_ groupId:String,
                                messageId: String,
                                storageId:String?,
                                onResult:((ResultOfOperation) -> Void)? = nil) {
        DispatchQueue.global(qos: .default).async {
            let dpGroup = DispatchGroup()
            var resultOfOperation = ResultOfOperation(presentedSucces: .MESSAGE_REMOVED)
            dpGroup.enter()
            self.removeMessage(groupId,messageId:messageId){ err in
                resultOfOperation.add(err)
                dpGroup.leave()
            }
            if let storageId = storageId{
                dpGroup.enter()
                self.removeImageFromStorage(groupId,storageId:storageId){ err in
                    resultOfOperation.add(err)
                    dpGroup.leave()
                }
            }
            dpGroup.enter()
            self.removeThreadIdFromGroup(groupId,threadId:messageId){ err in
                resultOfOperation.add(err)
                dpGroup.leave()
            }
            dpGroup.notify(queue: .main) {
                onResult?(resultOfOperation)
            }
            
        }
    }
    
    func removeMessage(_ groupId:String,messageId:String,onResult:((Error?) -> Void)? = nil){
        let doc = repo.getNewMessageDocument(groupId, messageId: messageId)
        doc.delete(){ err in
            //debugLog(object: err)
            onResult?(err)
        }
    }
    
    func removeImageFromStorage(_ groupId:String,storageId:String,onResult:((Error?) -> Void)? = nil){
        let ref = repo.getStorageReference(groupId: groupId, storageId: storageId)
        ref.delete(){ err in
            //debugLog(object: err)
            onResult?(err)
        }
    }
    
}

