//
//  AppUser.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-06-10.
//
import FirebaseFirestoreSwift
import SwiftUI
/*enum UserRole: Codable{
    case NOT_LOGGED_IN
    case ANONYMOUS_USER
    case REGISTERED_USER
    case ADMIN_USER
    case PAYED_USER
    case UNKNOWNED_USER_ROLE
    
    init(from decoder:Decoder) throws{
        let label = try decoder.singleValueContainer().decode(String.self)
        switch label{
        case "NOT_LOGGED_IN": self = .NOT_LOGGED_IN
        case "ANONYMOUS_USER": self = .ANONYMOUS_USER
        case "REGISTERED_USER": self = .REGISTERED_USER
        case "ADMIN_USER": self = .ADMIN_USER
        case "PAYED_USER": self = .PAYED_USER
        default: self = .UNKNOWNED_USER_ROLE
        }
    }
    
}*/

enum MessageDetail{
    case MESSAGE_MESSAGE
    case MESSAGE_DATE
    case MESSAGE_TUBE
    case MESSAGE_IMAGE
}

enum UserRole{
    case NOT_LOGGED_IN
    case ANONYMOUS_USER
    case REGISTERED_USER
    case ADMIN_USER
    case PAYED_USER
    case UNKNOWNED_USER_ROLE
}

enum RequestStatus: String,Codable{
    case RECIEVED_REQUEST
    case PENDING_REQUEST
    case CONFIRMED_REQUEST
    case NO_REQUEST
    
    /*init(from decoder:Decoder) throws{
        let label = try decoder.singleValueContainer().decode(String.self)
        switch label{
        case "RECIEVED_REQUEST": self = .RECIEVED_REQUEST
        case "PENDING_REQUEST": self = .PENDING_REQUEST
        case "CONFIRMED_REQUEST": self = .CONFIRMED_REQUEST
        case "NO_REQUEST": self = .NO_REQUEST
        default: self = .NO_REQUEST
        }
    }*/
     
}

enum UserMode: String,Codable{
    case USER_HIDDEN
    case USER_PUBLIC
}

extension UserMode{
    func userIsPublic() -> Bool{
        switch self{
        case .USER_HIDDEN: return false
        case .USER_PUBLIC: return true
        }
    }
    
    static func boolToUserModeString(_ value:Bool) -> String{
        return value ? UserMode.USER_PUBLIC.rawValue : UserMode.USER_HIDDEN.rawValue
    }
}

extension RequestStatus{
    func searchResultLabel() -> String{
        switch self{
        case .RECIEVED_REQUEST: return "Awaiting your response..."
        case .PENDING_REQUEST: return "Request sent..."
        case .CONFIRMED_REQUEST: return ""
        case .NO_REQUEST: return "Add to contacts"
        }
    }
    
    func describeYourSelf() -> String{
        switch self{
        case .RECIEVED_REQUEST: return "Request recieved"
        case .PENDING_REQUEST: return "Request sent"
        case .CONFIRMED_REQUEST: return "Friends"
        case .NO_REQUEST: return "Send Request"
        }
    }
    
    func describeYourSelfMedium() -> String{
        switch self{
        case .RECIEVED_REQUEST: return "Incoming request from:"
        case .PENDING_REQUEST: return "Request sent to:"
        case .CONFIRMED_REQUEST: return "Your friend:"
        case .NO_REQUEST: return "Send request to:"
        }
    }
    
    
}

typealias THREAD_IDS = String
typealias FRIEND_ID = String
typealias MESSAGE_ID = String
typealias USER_IDS = String

struct AppUser:Codable,Identifiable{
    @DocumentID var id: String?
    var userId: String?
    var email: String?
    var displayName: String?
    var userMode:UserMode?
    var groupIds:[FRIEND_ID:MESSAGE_ID]?
}

struct MessageGroup:Codable,Identifiable{
    @DocumentID var id: String?
    var groupId: String?
    var userIds:[USER_IDS]?
    var threadIds:[THREAD_IDS]?
    var groupInitialized:Date?
}

struct Message:Codable,Identifiable,Hashable{
    @DocumentID var id: String?
    var messageId: String?
    var groupId: String?
    var senderId:String?
    var message:String?
    var sharedTube:SharedTube?
    var date:Date?
    var storageId:String?
    var readBy:[String]?
    
    func hash(into hasher: inout Hasher) {
        return hasher.combine(senderId)
    }
        
    static func == (lhs: Message, rhs: Message) -> Bool {
        return lhs.messageId == rhs.messageId
    }
    
}

struct FeatureRequest:Codable,Identifiable{
    @DocumentID var id: String?
    var featureId: String?
    var email: String?
    var title:String?
    var description: String?
    var date:Date?
    var storageId:String?
    
}

struct IssueReport:Codable,Identifiable{
    @DocumentID var id: String?
    var issueId: String?
    var email: String?
    var description: String?
    var date:Date?
    var storageId:String?
}

struct SharedTube:Codable{
    var dimension:CGFloat?
    var segment:CGFloat?
    var steel:CGFloat?
    var grader:CGFloat?
    var radie:CGFloat?
    var lena:CGFloat?
    var lenb:CGFloat?
    var center:CGFloat?
}

struct Contact:Codable,Identifiable,Hashable{
    var id:String?
    var userId: String?
    var email: String?
    var displayName: String?
    var tag:[String]?
    var status:RequestStatus?
    var groupId:MESSAGE_ID?
    
    var initial:String{
        (displayName?.isEmpty ?? true) ? (email?.first?.uppercased() ?? "?") : (displayName?.first?.uppercased() ?? "?")
    }
    
    var displayInfo:String{
        (displayName?.isEmpty ?? true) ? (email ?? "?") : (displayName ?? "?")
    }
    
    func hash(into hasher: inout Hasher) {
        return hasher.combine(userId)
    }
        
    static func == (lhs: Contact, rhs: Contact) -> Bool {
        return lhs.userId == rhs.userId
    }
    
    mutating func setNewGroupId(){
        groupId = UUID().uuidString
    }
    
}
