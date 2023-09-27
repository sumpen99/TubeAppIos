//
//  FirestoreDeleteAccount.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-09-17.
//

import SwiftUI

extension FirestoreViewModel{
    
    func deleteAccount(onResult:((ResultOfOperation) -> Void)? = nil){
        DispatchQueue.global(qos: .default).async {
            let dpGroup = DispatchGroup()
            var resultOfOperation = ResultOfOperation(presentedSucces: .ACCOUNT_DELETED)
            dpGroup.enter()
            self.deleteMeFromContacts(){ errors in
                resultOfOperation.addAll(errors)
                dpGroup.leave()
            }
            dpGroup.enter()
            self.removeUserRequestDocument(){ err in
                resultOfOperation.add(err)
                dpGroup.leave()
            }
            dpGroup.enter()
            self.removeUserDocument(){ err in
                resultOfOperation.add(err)
                dpGroup.leave()
            }
            dpGroup.notify(queue: .main) {
                onResult?(resultOfOperation)
            }
        }
    }
    
    func deleteMeFromContacts(onResult:(([Error]) -> Void)? = nil){
        var errors:[Error] = []
        for initial in confirmedContacts.keys{
            for contact in confirmedContacts[initial] ?? []{
                removeMyConnectionFrom(contact){ err in
                    if let err = err{
                        errors.append(err)
                    }
                }
            }
        }
        onResult?(errors)
    }
}
