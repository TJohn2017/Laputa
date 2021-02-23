//
//  MainPageInputCanvas.swift
//  Laputa
//
//  Created by Daniel Guillen on 2/16/21.
//

import SwiftUI

struct MainPageInputCanvas: View {
    @Environment(\.managedObjectContext) private var viewContext

    @Binding var showingInputSheet: Bool

    @State var name: String = ""
    
    func saveCanvas() {
        guard self.name != "" else {return}
        let newCanvas = Canvas(context: viewContext)
        newCanvas.id = UUID()
        newCanvas.dateCreated = Date()
        newCanvas.title = name
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        
        showingInputSheet = false
    }
    
    var body: some View {
        Form {
            Section(header: Text("Canvas Info")) {
                HStack {
                    Text("Name")
                    TextField("Required", text: $name).multilineTextAlignment(.trailing)
                }
            }
            
            Button(action: saveCanvas) {
                Text("Add Canvas")
            }
        }
    }
}

struct MainPageInputCanvas_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper()
    }
    
    struct PreviewWrapper: View {
        @State var showingInputSheet = true

        var body: some View {
            
            return MainPageInputCanvas(
                showingInputSheet: $showingInputSheet
            ).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
}
