//
//  FirestoreDocumentExists.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-09-17.
//

import SwiftUI

extension FirestoreViewModel{
    func checkIfUserDocumentExists(onResult:((Error?,Bool) -> Void)? = nil){
        guard let userId = FirebaseAuth.userId else { onResult?(FirebaseError.MISSING_USER_ID,false);return; }
        let doc = repo.userDocument(userId)
        doc.getDocument{ snapshot, error in
            guard let snapshot = snapshot else { onResult?(FirebaseError.EMPTY_USER_DOCUMENT,false);return; }
            onResult?(nil,snapshot.exists)
        }
    }
    
    func checkIfUserRequestDocumentExists(onResult:((Error?,Bool) -> Void)? = nil){
        guard let userId = FirebaseAuth.userId else { onResult?(FirebaseError.MISSING_USER_ID,false);return; }
        let doc = repo.userRequestDocument(userId)
        doc.getDocument{ snapshot, error in
            guard let snapshot = snapshot else { onResult?(FirebaseError.EMPTY_USER_REQUEST_DOCUMENT,false);return; }
            onResult?(nil,snapshot.exists)
        }
    }
    
    func checkIfMessageGroupDocumentExists(_ groupId:String,onResult:((Error?,Bool) -> Void)? = nil){
        let doc = repo.messageGroupDocument(groupId)
        doc.getDocument{ snapshot, error in
            guard let snapshot = snapshot else { onResult?(FirebaseError.EMPTY_GROUP_MESSAGE_DOCUMENT,false);return; }
            onResult?(nil,snapshot.exists)
        }
    }
}
