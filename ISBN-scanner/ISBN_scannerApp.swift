//
//  ISBN_scannerApp.swift
//  ISBN-scanner
//
//  Created by 藍藍開發 on 2023/2/13.
//

import SwiftUI

@main
struct ISBN_scannerApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
