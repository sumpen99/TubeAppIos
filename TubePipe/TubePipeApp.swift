//
//  TubePipeApp.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-06-10.
//

import SwiftUI

@main
struct TubePipeApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @Environment(\.scenePhase) private var phase
    @StateObject var firebaseAuth = FirebaseAuth()
    @StateObject var firestoreViewModel = FirestoreViewModel()
    @StateObject var navigationViewModel = NavigationViewModel()
    @StateObject var coreDataViewModel = CoreDataViewModel()
    @StateObject var globalDialogPresentation = GlobalLoadingPresentation()
    let persistenceController = PersistenceController.shared
    
    
    var body: some Scene {
        StyledWindowGroup {
            ContentView()
            .environmentObject(firebaseAuth)
            .environmentObject(firestoreViewModel)
            .environmentObject(navigationViewModel)
            .environmentObject(coreDataViewModel)
            .environmentObject(globalDialogPresentation)
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
