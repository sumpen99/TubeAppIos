//
//  PasswordHelper.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-06-11.
//

import SwiftUI

struct NonSpecialCars {
    static let lower = "abcdefghijklmnopqrstuvwxyz"
    static let upper = lower.uppercased()
    static let numbers = "0123456789"
    static let validChars = Array(lower+upper+numbers)
    
}

enum PasswordLevel: Int {
    case NONE = 0
    case WEAK = 1
    case MEDIUM = 2
    case STRONG = 3
}

enum PasswordPassedChecks{
    case NOT_ACCEPTED
    case ACCEPTED
}

struct PasswordHelper {
    private(set) var passwordsIsAMatch: PasswordPassedChecks = .NOT_ACCEPTED
    private(set) var passwordsLevel: PasswordLevel = .NONE
    var emailText:String = ""
    var displayText:String = ""
    
    let nonSpecialChars = NonSpecialCars.validChars
    
    var password: String = "" {
        didSet {
            self.checkIfPasswordIsAcceptable()
        }
    }
    
    var confirmedPassword: String = "" {
        didSet {
            self.checkIfPasswordIsAMatch()
        }
    }
    
    
    mutating func checkIfPasswordIsAcceptable() {
        let numOfSpecialChars = self.password.filter{ !self.nonSpecialChars.contains($0)}.count
        if self.password.count < MIN_PASSWORD_LEN{
            self.passwordsLevel = .NONE
        } else if numOfSpecialChars == 0 {
            self.passwordsLevel = .WEAK
        } else if numOfSpecialChars == 1 {
            self.passwordsLevel = .MEDIUM
        } else {
            self.passwordsLevel = .STRONG
        }
        checkIfPasswordIsAMatch()
    }
    
    mutating func checkIfPasswordIsAMatch(){
        if self.passwordsLevel != .NONE && self.confirmedPassword == self.password {
            self.passwordsIsAMatch = .ACCEPTED
        }
        else{ self.passwordsIsAMatch = .NOT_ACCEPTED}
    }
    
}
