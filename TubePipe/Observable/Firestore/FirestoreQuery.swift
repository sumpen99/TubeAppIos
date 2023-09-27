//
//  FirestoreQuery.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-09-17.
//

import SwiftUI

extension FirestoreViewModel{
    func queryUsers(_ searchText:String){
        guard let userId = FirebaseAuth.userId else { return }
        let ref = repo.userRequestCollection
        ref
            .whereField("tag", arrayContains: searchText)
            .whereField("userId", isNotEqualTo: userId)
            .getDocuments(){ [weak self] (snapshot, err) in
                guard let documents = snapshot?.documents,
                      let strongSelf = self else { return }
                
                var contacts:[Contact] = []
                for document in documents {
                    guard let email = document.get("email") as? String,
                          let uid = document.get("userId") as? String else { continue }
                    
                    let displayName = document.get("displayName") as? String ?? ""
                    let initial = displayName.isEmpty ? (email.first?.uppercased() ?? "?") :
                    (displayName.first?.uppercased() ?? "?")
                    
                    let status = strongSelf.checkForExistingRequestConnection(uid,initial: initial)
                    contacts.append(Contact(
                        userId: uid,
                        email: email,
                        displayName: displayName,
                        tag:nil,
                        status: status))
                }
                strongSelf.contactSuggestions = contacts
            }
    }
    
}
 
