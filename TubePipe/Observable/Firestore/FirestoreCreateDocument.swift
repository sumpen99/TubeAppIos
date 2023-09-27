//
//  FirestoreCreateDocument.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-09-17.
//

import SwiftUI

extension FirestoreViewModel{
    func createAppUserDocument(onResult:((Error?) -> Void)? = nil) {
        guard let user = createNewAppUser(),
              let userId = user.userId else { onResult?(FirebaseError.MISSING_USER_ID);return; }
        let doc = repo.userDocument(userId)
        do{
            try doc.setData(from:user){ err in
                onResult?(err)
            }
        }
        catch{
            onResult?(FirebaseError.TRY_SET_DATA_FAILED(message: error.localizedDescription))
        }
    }
    
    func createAppUserRequestDocument(_ contact: Contact,onResult:((Error?) -> Void)? = nil) {
        guard let userId = contact.userId else { onResult?(FirebaseError.MISSING_USER_ID);return; }
        let doc = repo.userRequestDocument(userId)
        do{
            try doc.setData(from:contact){ err in
                onResult?(err)
            }
        }
        catch{
            onResult?(FirebaseError.TRY_SET_DATA_FAILED(message: error.localizedDescription))
        }
    }
    
    func createMessageGroupDocument(_ group: MessageGroup,groupId:String,onResult:((Error?) -> Void)? = nil) {
        let doc = repo.messageGroupDocument(groupId)
        do{
            try doc.setData(from:group){ err in
                onResult?(err)
            }
        }
        catch{
            onResult?(FirebaseError.TRY_SET_DATA_FAILED(message: error.localizedDescription))
        }
    }
    
}
  

