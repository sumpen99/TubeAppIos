//
//  FirestoreGetDocument.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-09-17.
//

import SwiftUI

extension FirestoreViewModel{
    func getThreadDocumentsFromGroup(_ groupId:String){
        var newMessages:[Message] = []
        let col = repo.messageGroupThreadCollection(groupId)
        col.order(by: "date",descending: true).limit(to: 1).getDocuments{ [weak self] (snapshot, error) in
            guard let documents = snapshot?.documents,
                  let strongSelf = self else{ return }
            for document in documents{
                guard let message = try? document.data(as : Message.self)
                else{ continue }
                newMessages.append(message)
            }
            strongSelf.messageGroups[groupId] = newMessages
        }
    }
    
    func loadThreadDocumentsFromContact(_ groupId:String?){
        var newMessages:[Message] = []
        contactMessages.removeAll()
        guard let groupId = groupId else { return }
        let col = repo.messageGroupThreadCollection(groupId)
        col.order(by: "date",descending: false).getDocuments{ [weak self] (snapshot, error) in
            guard let documents = snapshot?.documents,
                  let strongSelf = self else{ return }
            for document in documents{
                guard let message = try? document.data(as : Message.self)
                else{ continue }
                newMessages.append(message)
            }
            strongSelf.contactMessages = newMessages
        }
        
    }
    
}
