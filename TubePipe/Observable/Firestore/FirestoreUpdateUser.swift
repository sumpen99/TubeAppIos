//
//  FirestoreUpdateUser.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-09-17.
//

import SwiftUI

extension FirestoreViewModel{
    
    func saveUpdatedUserMode(contact:Contact,
                             userId:String,
                             displayName:String,
                             allowSharing:Bool,
                             userModeHasChanged:Bool,
                             newUserModeStr:String,
                             tagContainer:[String],
                             onResult:((ResultOfOperation) -> Void)? = nil){
        
        DispatchQueue.global(qos: .default).async {
            let dpGroup = DispatchGroup()
            var resultOfOperation = ResultOfOperation(presentedSucces: .SAVED_SUCCESSFULLY)
            dpGroup.enter()
            self.updateUserWithNameOrMode(
                newDisplayName: displayName,
                newUserMode: newUserModeStr){ err in
                resultOfOperation.add(err)
                dpGroup.leave()
            }
            dpGroup.enter()
            if userModeHasChanged{
                if allowSharing{
                    self.createAppUserRequestDocument(contact){ err in
                        resultOfOperation.add(err)
                        dpGroup.leave()
                    }
                }
                else{
                    self.removeUserRequestDocument(){ err in
                        resultOfOperation.add(err)
                        dpGroup.leave()
                    }
                }
            }
            else {
                self.checkIfUserRequestDocumentExists(){ error,documentExists in
                   if documentExists{
                       self.updateUserRequestWithTag(tagContainer,displayName:displayName){ err in
                           resultOfOperation.add(err)
                           dpGroup.leave()
                       }
                   }
                   else{
                       resultOfOperation.add(error)
                       dpGroup.leave()
                   }
               }
            }
            dpGroup.notify(queue: .main) {
                onResult?(resultOfOperation)
            }
        }
    }
}
