//
//  learn_itaApp.swift
//  learn-ita
//
//  Created by Sahaya Muthukani Gnanadurai on 08/04/26.
//

import SwiftUI
import CoreData

@main
struct learn_itaApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
