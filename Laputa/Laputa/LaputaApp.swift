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
    let host = HostInfo(alias:"claire's laptop", hostname:"192.168.1.11", username:"clairemai", usePassword:true, password:"macaron")
    var body: some Scene {
        WindowGroup {
            
            /* SwiftUITerminal(host: host)*/
            
           ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
