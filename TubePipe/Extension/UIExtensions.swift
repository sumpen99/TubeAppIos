//
//  UIExtensions.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-08-21.
//

import SwiftUI

extension UITabBar{
    static func changeAppearance(){
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = UIColor(Color(hex: 0xf0f4f5).opacity(0.9))
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        
    }
}

extension UINavigationBar {
    static func changeAppearance(clear: Bool) {
        let appearance = UINavigationBarAppearance()
        
        if clear {
            appearance.configureWithTransparentBackground()
        } else {
            appearance.backgroundColor = UIColor(Color.black.opacity(0.9))
        }
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        
    }
    
    static func changeAppearance(){
        let appearance = UINavigationBarAppearance()
        
        appearance.backgroundColor = UIColor(Color(hex: 0xf0f4f5).opacity(0.3))

        let attrsLarge: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.black,
            //.font: UIFont.monospacedDigitSystemFont(ofSize: 20, weight: .black)
        ]
        let attrsSmall: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.black,
            //.font: UIFont.monospacedSystemFont(ofSize: 20, weight: .black)
        ]
        appearance.titleTextAttributes = attrsSmall
        appearance.largeTitleTextAttributes = attrsLarge
        appearance.shadowColor = UIColor(Color.darkGray.opacity(0.3))
      
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        
        UINavigationBar.appearance().titleTextAttributes = attrsLarge
        UINavigationBar.appearance().largeTitleTextAttributes = attrsLarge
    }
}

extension UIView{
    
    static func changeUIAlertTintColor(){
        UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self])
            .tintColor = UIColor(Color.systemBlue)
    }
}


extension UIApplication {
    var keyWindow: UIWindow? {
        connectedScenes
            .compactMap {
                $0 as? UIWindowScene
            }
            .flatMap {
                $0.windows
            }
            .first {
                $0.isKeyWindow
            }
    }
}

extension UIDevice {
    static let deviceDidShakeNotification = Notification.Name(rawValue: "deviceDidShakeNotification")
}

extension UIWindow {
     open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            NotificationCenter.default.post(name: UIDevice.deviceDidShakeNotification, object: nil)
        }
     }
}

extension UIEdgeInsets {
    var swiftUiInsets: EdgeInsets {
        EdgeInsets(top: top, leading: left, bottom: bottom, trailing: right)
    }
}

extension UIScreen{
    static let screenWidth = UIScreen.main.bounds.size.width
    static let screenHeight = UIScreen.main.bounds.size.height
    static let screenSize = UIScreen.main.bounds.size
}
