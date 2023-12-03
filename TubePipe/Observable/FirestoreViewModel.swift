//
//  FirebaseViewModel.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-06-10.
//
import SwiftUI
import Firebase
import OrderedCollections

enum FirebaseError: Error {
    case EMPTY_SNAPSHOT
    case EMPTY_GROUP_MESSAGE_DOCUMENT
    case EMPTY_USER_REQUEST_DOCUMENT
    case EMPTY_USER_DOCUMENT
    case NEW_GROUP_MESSAGE_NIL
    case WEAK_SELF_ERROR
    case MISSING_GROUP_ID
    case MISSING_USER_ID
    case MISSING_CONTACT
    case MISSING_STRONGSELF
    case MISSING_USER_DISPLAY_NAME
    case FAILED_TO_SEND_MESSAGE
    case FAILED_TO_UPLOAD_IMAGE
    case FAILED_TO_CONVERT_DATA_TO_UIIMAGE
    case FAILED_TO_DOWNLOAD_IMAGE(message:String)
    case TRY_SET_DATA_FAILED(message:String)
    case OPTIONAL_ERROR(message:String)
    case UNEXPECTED_ERROR
}

extension FirebaseError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .WEAK_SELF_ERROR: return "Weak self failed"
        case .EMPTY_SNAPSHOT: return "Snapshot returned empty"
        case .EMPTY_GROUP_MESSAGE_DOCUMENT: return "Snapshot returned empty group message document"
        case .EMPTY_USER_DOCUMENT: return "Snapshot returned empty user document"
        case .EMPTY_USER_REQUEST_DOCUMENT: return "Snapshot returned empty request document"
        case .NEW_GROUP_MESSAGE_NIL: return "New MessageGroup returned nil"
        case .MISSING_GROUP_ID: return "WE DONT HAVE VALID GROUP_ID"
        case .MISSING_USER_ID: return "WE DONT HAVE VALID USER_ID"
        case .MISSING_CONTACT: return "We dont have a valid contact"
        case .MISSING_STRONGSELF: return "Unexpected error"
        case .MISSING_USER_DISPLAY_NAME: return "Please provide a valid displayname"
        case .FAILED_TO_SEND_MESSAGE: return "Failed to send message"
        case .FAILED_TO_UPLOAD_IMAGE: return "Failed to upload image"
        case .FAILED_TO_CONVERT_DATA_TO_UIIMAGE: return "Unexpected error while fetching data from server"
        case .FAILED_TO_DOWNLOAD_IMAGE(message: let message): return"FAILED_TO_DOWNLOAD_IMAGE: \(message)"
        case .TRY_SET_DATA_FAILED(message: let message): return "TRY_SET_DATA_FAILED: \(message)"
        case .OPTIONAL_ERROR(message: let message): return "\(message)"
        case .UNEXPECTED_ERROR: return "Unexpected error"
        }
    }
}

class FirestoreViewModel: ObservableObject{
    let repo = FirestoreRepository()
    typealias USERID = String
    typealias INITIAL = String
    typealias LISTENER_ID = String
    @Published var recievedContacts:OrderedDictionary<USERID,Contact> = [:]
    @Published var pendingContacts:OrderedDictionary<USERID,Contact> = [:]
    @Published var confirmedContacts:OrderedDictionary<INITIAL,[Contact]> = [:]
    @Published var messageGroups:OrderedDictionary<USERID,[Message]> = [:]
    @Published var contactSuggestions:[Contact] = []
    @Published var contactMessages:[Message] = []
    @Published var currentUser:AppUser?
    var listenerContainer:[LISTENER_ID:ListenerRegistration?] = [:]
    
    func closeThisInstanceOfFirebase(){
        recievedContacts.removeAll()
        pendingContacts.removeAll()
        confirmedContacts.removeAll()
        messageGroups.removeAll()
        contactSuggestions.removeAll()
        contactMessages.removeAll()
        listenerContainer.removeAll()
        currentUser = nil
    }
    
    deinit{
        debugLog(object: "deinit firestoreviewmodel")
    }
  
}
