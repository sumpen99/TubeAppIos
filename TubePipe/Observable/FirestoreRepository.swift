//
//  FirebaseRepository.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-06-10.
//

import FirebaseFirestore
import FirebaseStorage

enum ScreenShotFolder:String{
    case FEATURE_REQUEST = "FEATURE"
    case REPORT_ISSUE = "ISSUE"
}


class FirestoreRepository{
    private let firestoreDB = Firestore.firestore()
    private let firestoreStorage = Storage.storage()
    
    //USER
    private let APP_USER_COLLECTION = "USERS"
    private let APP_REQUEST_COLLECTION = "REQUESTS"
    
    //USER CONTACTS
    private let REQUESTS_PENDING = "REQUESTS_PENDING"
    private let REQUESTS_RECIEVED = "REQUESTS_RECIEVED"
    private let REQUESTS_CONFIRMED = "REQUESTS_CONFIRMED"
    
    // TUBE MESSAGE
    private let MESSAGE_GROUP = "MESSAGES"
    private let MESSAGE_THREAD = "THREAD"
    
    // FEATURE REQUEST
    private let FEATURE_REQUEST = "FEATURE_REQUEST"
    
    // ISSUE REPORT
    private let ISSUE_REPORT = "ISSUE_REPORT"
    
    //STORAGE
    private let STORAGE_GROUP = "GROUP"
    private let STORAGE_SCREENSHOT = "SCREENSHOT"
    
    var messageGroupCollection: CollectionReference{ firestoreDB.collection(MESSAGE_GROUP) }
    var userRequestCollection: CollectionReference{ firestoreDB.collection(APP_REQUEST_COLLECTION) }
    
    
    //MARK: - TOP LEVEL USER
    func userDocument(_ userId:String) -> DocumentReference{
        return firestoreDB
            .collection(APP_USER_COLLECTION)
            .document(userId)
    }
    
    func userRequestDocument(_ userId:String) -> DocumentReference{
        return firestoreDB
            .collection(APP_REQUEST_COLLECTION)
            .document(userId)
    }
    
    func messageGroupDocument(_ groupId:String) -> DocumentReference{
        return firestoreDB
            .collection(MESSAGE_GROUP)
            .document(groupId)
    }
    
    func featureRequestDocument(_ featureId:String) -> DocumentReference{
        return firestoreDB
            .collection(FEATURE_REQUEST)
            .document(featureId)
    }
    
    func issueReportDocument(_ issueId:String) -> DocumentReference{
        return firestoreDB
            .collection(ISSUE_REPORT)
            .document(issueId)
    }
    
    func messageGroupThreadCollection(_ groupId:String) -> CollectionReference{
        return firestoreDB
            .collection(MESSAGE_GROUP)
            .document(groupId)
            .collection(MESSAGE_THREAD)
    }
   
    //MARK: - SUBLEVEL REQUEST
    func requestPendingDocument(_ userId:String,requestId:String) -> DocumentReference{
        return firestoreDB
            .collection(APP_REQUEST_COLLECTION)
            .document(userId)
            .collection(REQUESTS_PENDING)
            .document(requestId)
    }
    func requestRecievedDocument(_ userId:String,requestId:String) -> DocumentReference{
        return firestoreDB
            .collection(APP_REQUEST_COLLECTION)
            .document(userId)
            .collection(REQUESTS_RECIEVED)
            .document(requestId)
    }
    func requestConfirmedDocument(_ userId:String,requestId:String) -> DocumentReference{
        return firestoreDB
            .collection(APP_REQUEST_COLLECTION)
            .document(userId)
            .collection(REQUESTS_CONFIRMED)
            .document(requestId)
    }
    
    func requestPendingCollection(_ userId:String) -> CollectionReference{
        return firestoreDB
            .collection(APP_REQUEST_COLLECTION)
            .document(userId)
            .collection(REQUESTS_PENDING)
    }
    func requestRecievedCollection(_ userId:String) -> CollectionReference{
        return firestoreDB
            .collection(APP_REQUEST_COLLECTION)
            .document(userId)
            .collection(REQUESTS_RECIEVED)
    }
    func requestConfirmedCollection(_ userId:String) -> CollectionReference{
        return firestoreDB
            .collection(APP_REQUEST_COLLECTION)
            .document(userId)
            .collection(REQUESTS_CONFIRMED)
    }
    
    //MARK: - TUBE MESSAGES
    func getNewMessageDocument(_ groupId:String,messageId:String) -> DocumentReference{
        return firestoreDB
            .collection(MESSAGE_GROUP)
            .document(groupId)
            .collection(MESSAGE_THREAD)
            .document(messageId)
    }
    
    func getStorageReference(groupId:String,storageId:String) -> StorageReference{
        return firestoreStorage.reference().child("\(STORAGE_GROUP)/\(groupId)/\(storageId).png")
    }
    
    func getScreenShotReference(storageId:String,folder:ScreenShotFolder) -> StorageReference{
        return firestoreStorage.reference().child("\(folder.rawValue)/\(storageId).png")
    }
    
  /*
    
    func setMetaDataAs(_ dataType:String) -> StorageMetadata{
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpg"
        return metadata
    }*/
    
}
