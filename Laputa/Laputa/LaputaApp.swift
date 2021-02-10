//
//  LaputaApp.swift
//  Laputa
//
//  Created by Tyler Johnson on 2/2/21.
//

import SwiftUI

@main
struct LaputaApp: App {
    let persistenceController = PersistenceController.shared
    var host:Host = Host(alias: "Claire MacPro", hostname: "192.168.1.11", usePassword: true, username: "clairemai", password: "macaron", lastUsed: Date ())
    
    var body: some Scene {
        WindowGroup {
            SwiftUITerminal(host: host, createNew: true, interactive: true).navigationBarTitle (Text (host.alias), displayMode: .inline)
           // ContentView()
              //  .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
