//
//  Persistence.swift
//  Laputa
//
//  Created by Tyler Johnson on 2/2/21.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for i in 0..<10 {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()
            
            let newCodeCard = CodeCard(context: viewContext)
            newCodeCard.id = UUID()
            newCodeCard.text = "Hello \(i)"
            newCodeCard.locX = 10.0 + Double(i) * 5.0
            newCodeCard.locY = 10.0 + Double(i) * 5.0
            
            let newCanvas = Canvas(context: viewContext)
            newCanvas.id = UUID()
            newCanvas.title = "Test canvas"
            newCanvas.dateCreated = Date()
        }
        
        for index in 0..<10 {
            // Instantiate preview Item entities.
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()
            newItem.id = Int32(index)
            
            // Instantiate preview Host entities.
            let newHost = Host(context: viewContext)
            newHost.host = "host_\(index)"
            newHost.name = "Name #\(index)"
            newHost.password = "password_\(index)"
            newHost.port = "22"
            newHost.username = "username_\(index)"
        }
        
        let newHost = Host(context: viewContext)
        newHost.name = "Laputa"
        newHost.host = "159.65.78.184"
        newHost.username = "laputa"
        newHost.port = "22"
        newHost.password = "LaputaIsAwesome"
        
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Laputa")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                Typical reasons for an error here include:
                * The parent directory does not exist, cannot be created, or disallows writing.
                * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                * The device is out of space.
                * The store could not be migrated to the current model version.
                Check the error message to determine what the actual problem was.
                */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
    }
}
