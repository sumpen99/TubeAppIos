//
//  FirestoreContacts.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-09-17.
//

import SwiftUI

extension FirestoreViewModel{
        
    func acceptContactRequestFrom(_ otherUser: Contact,
                                  onResult:((ResultOfOperation) -> Void)? = nil) {
        DispatchQueue.global(qos: .default).async {
            let dpGroup = DispatchGroup()
            var resultOfOperation = ResultOfOperation(presentedSucces: .CONTACT_REQUEST_ACCEPTED)
            dpGroup.enter()
            self.addMyselfAsFriendToOther(otherUser){ err in
                resultOfOperation.add(err)
                dpGroup.leave()
            }
            dpGroup.enter()
            self.addToMyFriendsWithOther(otherUser){ err in
                resultOfOperation.add(err)
                dpGroup.leave()
            }
            dpGroup.enter()
            self.updateUserWithNewGroupId(groupId: otherUser.groupId, otherUserId: otherUser.userId){ err in
                resultOfOperation.add(err)
                dpGroup.leave()
            }
            dpGroup.notify(queue: .main) {
                onResult?(resultOfOperation)
            }
            
        }
    }
    
    func addMyselfAsFriendToOther(_ otherUser: Contact,onResult:((Error?) -> Void)? = nil) {
        guard let userId = otherUser.userId,
              let myId = FirebaseAuth.userId else { onResult?(FirebaseError.MISSING_USER_ID);return; }
        guard let mySelfAsContact = mySelfAsContactWithGroupIdAndStatus(.CONFIRMED_REQUEST, groupId: otherUser.groupId)
        else { onResult?(FirebaseError.MISSING_USER_ID);return; }
        let doc = repo.requestConfirmedDocument(userId,requestId: myId)
        do{
            try doc.setData(from:mySelfAsContact){ err in
                onResult?(err)
            }
        }
        catch{
            onResult?(FirebaseError.TRY_SET_DATA_FAILED(message: error.localizedDescription))
        }
    }
    
    func addToMyFriendsWithOther(_ otherUser: Contact,onResult:((Error?) -> Void)? = nil) {
        guard let userId = otherUser.userId,
              let myId = FirebaseAuth.userId else { onResult?(FirebaseError.MISSING_USER_ID);return; }
        let doc = repo.requestConfirmedDocument(myId,requestId: userId)
        do{
            try doc.setData(from:otherUserAsContactWithStatus(.CONFIRMED_REQUEST, contact: otherUser)){ err in
                onResult?(err)
            }
        }
        catch{
            onResult?(FirebaseError.TRY_SET_DATA_FAILED(message: error.localizedDescription))
        }
    }
    
    func sendContactRequestTo(_ otherUser: Contact,
                              onResult:((ResultOfOperation) -> Void)? = nil) {
        DispatchQueue.global(qos: .default).async {
            let dpGroup = DispatchGroup()
            var resultOfOperation = ResultOfOperation(presentedSucces: .CONTACT_REQUEST_SENT)
            dpGroup.enter()
            self.setMyInfoInside(otherUser){ err in
                resultOfOperation.add(err)
                dpGroup.leave()
            }
            dpGroup.enter()
            self.setMySentInfoWith(otherUser){ err in
                resultOfOperation.add(err)
                dpGroup.leave()
            }
            dpGroup.enter()
            self.updateUserWithNewGroupId(groupId: otherUser.groupId, otherUserId: otherUser.userId){ err in
                resultOfOperation.add(err)
                dpGroup.leave()
            }
            dpGroup.notify(queue: .main) {
                onResult?(resultOfOperation)
            }
            
        }
    }
    
    
    func setMyInfoInside(_ otherUser: Contact,onResult:((Error?) -> Void)? = nil) {
        guard let userId = otherUser.userId,
              let myId = FirebaseAuth.userId else { onResult?(FirebaseError.MISSING_USER_ID);return; }
        guard let mySelfAsContact = mySelfAsContactWithGroupIdAndStatus(.RECIEVED_REQUEST,groupId: otherUser.groupId) else { onResult?(FirebaseError.MISSING_USER_ID);return; }
        let doc = repo.requestRecievedDocument(userId,requestId: myId)
        do{
            try doc.setData(from:mySelfAsContact){ err in
                onResult?(err)
            }
        }
        catch{
            onResult?(FirebaseError.TRY_SET_DATA_FAILED(message: error.localizedDescription))
        }
    }
    
    func setMySentInfoWith(_ otherUser: Contact,onResult:((Error?) -> Void)? = nil) {
        guard let userId = otherUser.userId,
              let myId = FirebaseAuth.userId else { onResult?(FirebaseError.MISSING_USER_ID);return; }
        let doc = repo.requestPendingDocument(myId,requestId: userId)
        do{
            try doc.setData(from:otherUserAsContactWithStatus(.PENDING_REQUEST, contact: otherUser)){ err in
                onResult?(err)
            }
        }
        catch{
            onResult?(FirebaseError.TRY_SET_DATA_FAILED(message: error.localizedDescription))
        }
    }
    
}
   

