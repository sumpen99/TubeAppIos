//
//  FirestoreGetDocument.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-09-17.
//

import SwiftUI

extension FirestoreViewModel{
    func getThreadDocumentsFromGroup(_ groupId:String){
        let col = repo.messageGroupThreadCollection(groupId)
        col.order(by: "date",descending: true).limit(to: 1).getDocuments{ [weak self] (snapshot, error) in
            guard let documents = snapshot?.documents,
                  let strongSelf = self else{ return }
            var newMessages:[Message] = []
            for doc in documents{
                guard let message = try? doc.data(as : Message.self)
                else{ continue }
                newMessages.append(message)
            }
            strongSelf.messageGroups[groupId] = newMessages
        }
    }
    
}
