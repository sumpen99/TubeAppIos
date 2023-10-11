//
//  ResultOfOperation.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-09-17.
//

import SwiftUI

enum PresentedResult:String{
    case SAVED_SUCCESSFULLY = "Saved successfully"
    case MESSAGE_SENT = "Message sent"
    case FEATURE_REQUEST = "Feature request submitted"
    case ISSUE_REPORT = "Issue report submitted"
    case MESSAGE_REMOVED = "Message removed"
    case CONTACT_REMOVED = "Contact removed"
    case CONTACT_REQUEST_REMOVED = "Request removed"
    case CONTACT_REQUEST_SENT = "Request sent"
    case CONTACT_REQUEST_ACCEPTED = "Request accepted"
    case ACCOUNT_DELETED = "Account is deleted"
    case DEFAULT_RESULT = ""
}

enum ErrorLevel{
    case CRITICAL
    case OPTIONAL
}

struct ResultOfOperation{
    var hasOptionalError:Bool = false
    var hasCriticalError:Bool = false
    var errors:[Error] = []
    let presentedSucces:PresentedResult
    
    mutating func add(_ err:Error?,isOptional:Bool = false,optionalText:String = ""){
        if let err = err{
            if isOptional{
                hasOptionalError = true
                let message = err.localizedDescription + "\n\(optionalText)"
                let op = FirebaseError.OPTIONAL_ERROR(message: message)
                errors.append(op)
                return
            }
            else{
                hasCriticalError = true
                errors.append(err)
            }
        }
    }
    
    mutating func addAll(_ listOfErrors:[Error]){
        if errors.isEmpty{ return }
        hasCriticalError = true
        errors.append(contentsOf: listOfErrors)
    }
    
    var isSuccess:Bool{ errors.isEmpty }
    
    var operationFailed:Bool{
        return hasCriticalError
    }
    
    var operationHasMessage:Bool{
        hasCriticalError || hasOptionalError
    }
    
    var message:String{
        if errors.isEmpty { return presentedSucces.rawValue}
        return presentedErrorDescription()
    }
    
    func presentedErrorDescription() -> String{
        var presentedText = ""
        for err in errors{
            presentedText += "\(BULLET)\(err.localizedDescription)\n"
        }
        return presentedText
    }
    
}
