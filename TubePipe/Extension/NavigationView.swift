//
//  NavigationView.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-10-23.
//

import SwiftUI

extension UIApplication{
    static func connectedScenes() -> [UIWindow]{
        self.shared.connectedScenes.flatMap { ($0 as? UIWindowScene)?.windows ?? [] }
    }
    static func rootViewController() -> UIViewController?{
        let scenes = self.connectedScenes()
        debugLog(object: scenes.count)
        return scenes.first{ $0.isKeyWindow }?.rootViewController
    }
}

struct NavigationUtil {
    static func popToRootView(animated: Bool = false) {
        let rootUIViewController = UIApplication.rootViewController()
        if let uiNavController = findNavigationController(viewController:rootUIViewController){
            uiNavController.popViewController(animated: animated)
        }
    }
    
    static private func findNavigationController(viewController: UIViewController?) -> UINavigationController? {
        guard let viewController = viewController else {
            return nil
        }
        if let navigationController = viewController as? UITabBarController {
            //debugLog(object: "found UITabBarController")
            return findNavigationController(viewController: navigationController.selectedViewController)
        }
        
        if let navigationController = viewController as? UINavigationController {
            //debugLog(object: "found UINavigationController")
            return navigationController
        }
        
        for childViewController in viewController.children {
            //debugLog(object: "found childViewController")
            return findNavigationController(viewController: childViewController)
        }
        
        return nil
    }
}
