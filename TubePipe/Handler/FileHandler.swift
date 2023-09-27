//
//  FileHandler.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-06-10.
//

import SwiftUI

/*var ordersFolder:URL? {
    guard let documentDirectory = documentDirectory else { return nil}
    
    let ordersFolder = documentDirectory.appendingPathComponent("orders")
    if !FileManager.default.fileExists(atPath: ordersFolder.absoluteString) {
        do{
            try FileManager.default.createDirectory(at: ordersFolder,
                                                    withIntermediateDirectories: true,
                                                    attributes: nil)
        }
        catch{
            return nil
        }
    }
    return ordersFolder
}

func removeAllOrdersFromFolder(){
    let fileManager = FileManager.default
    guard let ordersFolder = ordersFolder,
          let filePaths = try? fileManager.contentsOfDirectory(at: ordersFolder, includingPropertiesForKeys: nil, options: [])  else { return }
    for filePath in filePaths {
        do{
            try fileManager.removeItem(at: filePath)
        }
        catch{
 debugLog(object:error)
        }
    }
}

func removeOneOrderFromFolder(fileName:String){
    guard let filePath = getPdfUrlPath(fileName: fileName) else { return }
    do{
        try FileManager.default.removeItem(at: filePath)
    }
    catch{
 debugLog(object:error)
    }
}

func getPdfUrlPath(fileName:String) -> URL?{
    guard let ordersFolder = ordersFolder else { return nil }
    let filePath = fileName + ".pdf"
    let renderedUrl = ordersFolder.appending(path: filePath)
    return renderedUrl
}*/


var documentDirectory:URL? { FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first }

class FileHandler{
    
    static func getFileNameUrl(_ filename:String) -> URL?{
        guard let docDir = documentDirectory else {
            return nil
        }
        return docDir.appendingPathComponent(filename)
    }
    
    static func getAbsoluteFileNamePath(_ filename:String) -> String?{
        guard let docDir = documentDirectory else { return nil }
        return URL(fileURLWithPath: docDir.absoluteString).appendingPathComponent(filename).path
    }
    
    static func openPrivacySettings(){
        guard let url = URL(string: UIApplication.openSettingsURLString),
                UIApplication.shared.canOpenURL(url) else {
                    assertionFailure("Not able to open App privacy settings")
                    return
            }
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    static func removeFileFromDocuments(_ fileName:String,
                                        onFinishWriting : ((ThrowableResult) -> Void)? = nil){
        var throwableResult = ThrowableResult()
        guard let fileNameUrl = getFileNameUrl(fileName) else {
            throwableResult.value = "Unable to get directorypath as NSURL"
            throwableResult.finishedWithoutError = false
            onFinishWriting?(throwableResult)
            return
         }
        do {
            try FileManager.default.removeItem(at: fileNameUrl)
            throwableResult.value = "Successfully removed image from path \(fileNameUrl)"
            throwableResult.finishedWithoutError = true
        } catch  {
            throwableResult.value = error.localizedDescription
            throwableResult.finishedWithoutError = false
            
        }
        onFinishWriting?(throwableResult)
    }
    
    static func writeImageToDocuments(_ image:UIImage,
                                      fileName filename:String,
                                      onFinishWriting : ((ThrowableResult) -> Void)? = nil){
        var throwableResult = ThrowableResult()
        
        guard let data = image.jpegData(compressionQuality: 1) ?? image.pngData() else {
            throwableResult.value = "Unable to get UIImage from image"
            throwableResult.finishedWithoutError = false
            onFinishWriting?(throwableResult)
            return
        }
        guard let fileNameUrl = getFileNameUrl(filename) else {
            throwableResult.value = "Unable to get directorypath as NSURL"
            throwableResult.finishedWithoutError = false
            onFinishWriting?(throwableResult)
            return
        }
        do {
            try data.write(to: fileNameUrl)
            throwableResult.value = "Successfully wrote image to path \(fileNameUrl)"
            throwableResult.finishedWithoutError = true
        } catch {
            throwableResult.value = error.localizedDescription
            throwableResult.finishedWithoutError = false
        }
        
        onFinishWriting?(throwableResult)
    }
    
    static func getSavedImage(_ fileName: String,onFinishWriting : ((ThrowableResult) -> Void)? = nil){
        var throwableResult = ThrowableResult()
        throwableResult.finishedWithoutError = true
        guard let filePath = getAbsoluteFileNamePath(fileName) else{
            throwableResult.value = "Unable to getAbsoluteFileNameUrlPath"
            throwableResult.finishedWithoutError = false
            onFinishWriting?(throwableResult)
            return
        }
        throwableResult.value = UIImage(contentsOfFile:filePath)
        onFinishWriting?(throwableResult)
    }
    
}
