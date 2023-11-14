//
//  FirestoreQuery.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-09-17.
//

import SwiftUI
import Firebase
extension FirestoreViewModel{
    func queryUsers(_ searchText:String){
        guard let userId = FirebaseAuth.userId else { return }
        let query = repo.userRequestCollection
                    .whereFilter(Filter.andFilter([
                        Filter.whereField("tag", arrayContains: searchText),
                        Filter.whereField("userId", isNotEqualTo: userId)]))
        
        query.getDocuments(){ [weak self] (snapshot, err) in
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
        
    
    func isUsernameAlreadyPresent(_ userId:String,userName:String,action:@escaping ((Bool) ->Void)){
        repo.userRequestCollection
        .whereFilter(Filter.andFilter([
            Filter.whereField("displayName", isEqualTo: userName),
            Filter.whereField("userId", isNotEqualTo: userId)]))
        .getDocuments(){ (snapshot, err) in
            guard let documents = snapshot?.documents else { action(true); return }
            action(documents.count > 0)
            /*DispatchQueue.global(qos: .background).async {
                let obj = documents.first(where: { $0.get("displayName") as? String ?? "" == userName && $0.get("userId") as? String ?? "" != userId })
                DispatchQueue.main.async {
                    action?(obj != nil)
                }
            }*/
        }
    }
    
}
 
