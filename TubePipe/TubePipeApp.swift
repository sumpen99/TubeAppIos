//
//  TubePipeApp.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-06-10.
//

import SwiftUI
/*
 
 USE NAVMODEL AND POP VIEWS FROM PATH. SEEMS TO SOLVE MEMORY LEAKS FROM FIREBASE
 UPDATE 231106: IT DID NOT,  LISTENERREGISTRATION.REMOVE() MIGHT BE THE PROBLEM. SETTING TO NIL INSTEAD
 TO BE CONTINUED...
  
 */
@main
struct TubePipeApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @Environment(\.scenePhase) private var phase
    @StateObject var firebaseAuth = FirebaseAuth()
    @StateObject var firestoreViewModel = FirestoreViewModel()
    let persistenceController = PersistenceController.shared
  
    var body: some Scene {
        StyledWindowGroup {
            ContentView()
            .environmentObject(firebaseAuth)
            .environmentObject(firestoreViewModel)
            .environment(\.managedObjectContext,persistenceController.container.viewContext)
            .preferredWindowColor(Color.backgroundPrimary)
            .onChange(of: phase) { newPhase in
                try? persistenceController.saveContext()
                /*switch newPhase {
                case .active: debugLog(object:phase)
                case .inactive: debugLog(object:phase)
                case .background: debugLog(object:phase)
                @unknown default: debugLog(object:"Unknown Future Options")
              }*/
            }
        }
    }
    
}
