//
//  FirestoreMessages.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-09-17.
//

import SwiftUI

extension FirestoreViewModel{
    
    func sendNewMessage(_ message:Message,
                        groupId:String,
                        messageId:String,
                        imgData:Data?,
                        onResult:((ResultOfOperation) -> Void)? = nil) {
        DispatchQueue.global(qos: .default).async {
            let dpGroup = DispatchGroup()
            var resultOfOperation = ResultOfOperation(presentedSucces: .MESSAGE_SENT)
            dpGroup.enter()
            self.sendMessage(groupId,messageId: messageId,message: message){ err in
                resultOfOperation.add(err)
                dpGroup.leave()
            }
            if let data = imgData,
               let storageId = message.storageId{
                dpGroup.enter()
                self.uploadImageToStorage(groupId,storageId: storageId,imgData: data){ err in
                    resultOfOperation.add(err,isOptional: true,optionalText: "Failed to attach image to message.")
                    dpGroup.leave()
                }
            }
            dpGroup.enter()
            self.updateMessageGroupWithThreadId(messageId,groupId: groupId){ err in
                resultOfOperation.add(err)
                dpGroup.leave()
            }
            dpGroup.notify(queue: .main) {
                onResult?(resultOfOperation)
            }
        }
    }
    
    func sendMessage(_ groupId:String,messageId:String,message:Message,onResult: ((Error?) -> Void)? = nil){
        let doc = repo.getNewMessageDocument(groupId, messageId: messageId)
        do{
            try doc.setData(from:message){ err in
                onResult?(err)
            }
        }
        catch{
            onResult?(FirebaseError.TRY_SET_DATA_FAILED(message: error.localizedDescription))
        }
    }
    
    // MARK: - STORAGE UPLOAD IMAGE
    func uploadImageToStorage(_ groupId:String,storageId:String,imgData:Data,onResult: ((Error?) -> Void)? = nil){
        let ref = repo.getStorageReference(groupId: groupId, storageId: storageId)
        ref.putData(imgData,metadata: nil){ (metadata,error) in
            if let _ = metadata{ onResult?(nil) }
            else{ onResult?(FirebaseError.FAILED_TO_UPLOAD_IMAGE) }
        }
    }
    
    func downloadImageFromStorage(groupId:String,
                                  storageId:String,
                                  onResult:((Error?,UIImage?) -> Void)? = nil){
        let ref = repo.getStorageReference(groupId: groupId, storageId: storageId)
        ref.getData(maxSize: (MAX_STORAGE_PNG_SIZE)) { (data, error) in
            if let err = error {
                onResult?(FirebaseError.FAILED_TO_DOWNLOAD_IMAGE(message: err.localizedDescription),nil)
            }
            else {
                if let image = data {
                    onResult?(nil,UIImage(data: image))
                }
                else{
                    onResult?(FirebaseError.FAILED_TO_CONVERT_DATA_TO_UIIMAGE,nil)
                }
            }
            
        }
    }
}

