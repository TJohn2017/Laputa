//
//  LaputaApp.swift
//  Laputa
//
//  Created by Tyler Johnson on 2/2/21.
//

import SwiftUI
import SwiftTerm

@main
struct LaputaApp: App {
    let persistenceController = PersistenceController.shared
    var body: some Scene {
        WindowGroup {
            
            /* SwiftUITerminal(host: host)*/
            
           ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
