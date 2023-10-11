//
//  FirestoreAdmin.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-10-11.
//

import SwiftUI

extension FirestoreViewModel{
    
    func submitNewFeatureRequest(_ feature:FeatureRequest,
                                 featureId:String,
                                 imgData:Data?,
                                 onResult:((ResultOfOperation) -> Void)? = nil) {
        DispatchQueue.global(qos: .default).async {
            let dpGroup = DispatchGroup()
            var resultOfOperation = ResultOfOperation(presentedSucces: .FEATURE_REQUEST)
            dpGroup.enter()
            self.createFeatureRequestDocument(featureId,feature: feature){ err in
                resultOfOperation.add(err)
                dpGroup.leave()
            }
            if let data = imgData,
               let storageId = feature.storageId{
                dpGroup.enter()
                self.uploadScreenShotToStorage(storageId,folder: .FEATURE_REQUEST,imgData: data){ err in
                    resultOfOperation.add(err,isOptional: true,optionalText: "Failed to attach image to message.")
                    dpGroup.leave()
                }
            }
            dpGroup.notify(queue: .main) {
                onResult?(resultOfOperation)
            }
        }
    }
    
    func submitNewIssueReport(_ issue:IssueReport,
                            issueId:String,
                            imgData:Data?,
                            onResult:((ResultOfOperation) -> Void)? = nil) {
        DispatchQueue.global(qos: .default).async {
            let dpGroup = DispatchGroup()
            var resultOfOperation = ResultOfOperation(presentedSucces: .ISSUE_REPORT)
            dpGroup.enter()
            self.createIssueReportDocument(issueId,issue: issue){ err in
                resultOfOperation.add(err)
                dpGroup.leave()
            }
            if let data = imgData,
               let storageId = issue.storageId{
                dpGroup.enter()
                self.uploadScreenShotToStorage(storageId,folder: .REPORT_ISSUE,imgData: data){ err in
                    resultOfOperation.add(err,isOptional: true,optionalText: "Failed to attach image to message.")
                    dpGroup.leave()
                }
            }
            dpGroup.notify(queue: .main) {
                onResult?(resultOfOperation)
            }
        }
    }
    
    func createFeatureRequestDocument(_ featureId:String,feature: FeatureRequest,onResult:((Error?) -> Void)? = nil) {
        let doc = repo.featureRequestDocument(featureId)
        do{
            try doc.setData(from:feature){ err in
                onResult?(err)
            }
        }
        catch{
            onResult?(FirebaseError.TRY_SET_DATA_FAILED(message: error.localizedDescription))
        }
    }
    
    func createIssueReportDocument(_ issueId:String,issue: IssueReport,onResult:((Error?) -> Void)? = nil) {
        let doc = repo.issueReportDocument(issueId)
        do{
            try doc.setData(from:issue){ err in
                onResult?(err)
            }
        }
        catch{
            onResult?(FirebaseError.TRY_SET_DATA_FAILED(message: error.localizedDescription))
        }
    }
    
    func uploadScreenShotToStorage(_ storageId:String,
                                   folder:ScreenShotFolder,
                                   imgData:Data,
                                   onResult: ((Error?) -> Void)? = nil){
        let ref = repo.getScreenShotReference(storageId: storageId,folder: folder)
        ref.putData(imgData,metadata: nil){ (metadata,error) in
            debugLog(object: error?.localizedDescription)
            if let _ = metadata{ onResult?(nil) }
            else{ onResult?(FirebaseError.FAILED_TO_UPLOAD_IMAGE) }
        }
    }
}
