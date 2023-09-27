//
//  FirestoreUpdateData.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-09-17.
//

import SwiftUI
import Firebase
extension FirestoreViewModel{
    func updateUserWithNameOrMode(newDisplayName:String,newUserMode:String,onResult:((Error?) -> Void)? = nil){
        guard let userId = FirebaseAuth.userId else { return }
        let user = repo.userDocument(userId)
        user.updateData(["displayName": newDisplayName,"userMode":newUserMode]){ err in
            onResult?(err)
        }
    }
    
    func updateUserWithNewGroupId(groupId:String?,otherUserId:String?,onResult:((Error?) -> Void)? = nil){
        guard let userId = FirebaseAuth.userId,
              let groupId = groupId,
              let otherUserId = otherUserId else { onResult?(FirebaseError.MISSING_USER_ID);return }
        let user = repo.userDocument(userId)
        user.updateData(["groupIds.\(otherUserId)": groupId]){ err in
            onResult?(err)
        }
    }
    
    func removeGroupIdFromUser(otherUserId:String?,onResult:((Error?) -> Void)? = nil){
        guard let userId = FirebaseAuth.userId,
              let otherUserId = otherUserId else { onResult?(FirebaseError.MISSING_USER_ID);return }
        let user = repo.userDocument(userId)
        user.updateData( ["groupId.\(otherUserId)": FieldValue.delete()]) { err in
            onResult?(err)
        }
    }
    
    func updateUserRequestWithTag(_ tag:[String],displayName:String,onResult:((Error?) -> Void)? = nil){
        guard let userId = FirebaseAuth.userId else { return }
        let user = repo.userRequestDocument(userId)
        user.updateData(["tag": tag,"displayname":displayName]){ err in
            onResult?(err)
        }
    }
    
    func updateMessageGroupWithThreadId(_ threadId:String,groupId:String,onResult:((Error?) -> Void)? = nil){
        let messageGroup = repo.messageGroupDocument(groupId)
        messageGroup.updateData(["threadIds": FieldValue.arrayUnion([threadId])]){ err in
            onResult?(err)
        }
    }
    
    func removeThreadIdFromGroup(_ groupId:String,threadId:String,onResult:((Error?) -> Void)? = nil){
        let messageGroup = repo.messageGroupDocument(groupId)
        messageGroup.updateData(["threadIds.\(threadId)": FieldValue.delete()]){ err in
            onResult?(err)
        }
    }
    
}
