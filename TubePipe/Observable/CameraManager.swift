//
//  CameraManager.swift
//  TubePipe
//
//  Created by fredrik sundström on 2024-01-21.
//
import AVFoundation
import SwiftUI

@MainActor
class CameraManger:ObservableObject{
    @Published var permission:(isAuthorized:Bool,status:AVAuthorizationStatus) = (false,.notDetermined)
    
    private var currentStatus:(Bool,AVAuthorizationStatus) {
        get async {
            var status = AVCaptureDevice.authorizationStatus(for: .video)
            var isAuthorized = status == .authorized
            if status == .notDetermined {
                isAuthorized = await AVCaptureDevice.requestAccess(for: .video)
                status = AVCaptureDevice.authorizationStatus(for: .video)
            }
            return (isAuthorized:isAuthorized,status:status)
        }
    }
    
    func setUpCaptureSession() async {
        await permission = currentStatus
    }
    
    /*
    func requestPermission() async {
        let status =  AVCaptureDevice.authorizationStatus(for: .video)
        switch(status){
        case .authorized:
            permissionGranted = true
        case .notDetermined:
            permissionGranted = await AVCaptureDevice.requestAccess(for: .video)
        case .denied:
            permissionGranted = false
        case .restricted:
            permissionGranted = false
            
            
        @unknown default:
            permissionGranted = false
        }
                
    }*/
    /*
    func requestPermission(){
        
        AVCaptureDevice.requestAccess(for: .video, completionHandler: {accessGranted in
            DispatchQueue.main.async {
                self.permissionGranted = accessGranted
            }
        })
    }*/
}
/*
 .alert(isPresented: $isPrivacyResult, content: {
     onPrivacyAlert(
         actionPrimary: openPrivacySettings,
         actionSecondary: closeView)
 })
 
 .alert(isPresented: $isPrivacyResult, content: {
     onPrivacyAlert(actionPrimary: openPrivacySettings,
                    actionSecondary: {})
      
 })

 

 
 
 */
