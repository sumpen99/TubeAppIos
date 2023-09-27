//
//  FieldExtension.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-08-28.
//

import SwiftUI

enum Field:Int,Hashable{
    case FIND_STORED_TUBE
    case FIND_USER
    case SIGNUP_EMAIL
    case SIGNUP_SECURE_PASSWORD
    case SIGNUP_RETYPE_SECURE_PASSWORD
    case LOGIN_EMAIL
    case LOGIN_SECURE_PASSWORD
    case DOCUMENT_MESSAGE
    case PROFILE_NAME
    case PROFILE_DISPLAY_NAME
}

