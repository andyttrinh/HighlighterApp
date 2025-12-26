//
//  HighlighterAppApp.swift
//  HighlighterApp
//
//  Created by Andy Trinh on 12/26/25.
//

import SwiftUI
import CoreData

@main
struct HighlighterAppApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
