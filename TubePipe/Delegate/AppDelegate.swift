//
//  AppDelegate.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-06-10.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject,UIApplicationDelegate{
    
    static private(set) var instance: AppDelegate! = nil
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
            FirebaseApp.configure()
            AppDelegate.instance = self
            return true
    }
    
}
