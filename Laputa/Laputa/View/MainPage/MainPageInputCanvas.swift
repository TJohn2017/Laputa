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
    // if this is not nil, we are editing an existing canvas
    @Binding var selectedCanvas: Canvas?

    @State var name: String = ""
    
    // fill form with existing canvas information if there is one
    func populate() {
        if self.selectedCanvas != nil {
            name = selectedCanvas!.title!
        }
    }
    
    func saveCanvas() {
        guard self.name != "" else {return}
        
        // creating a new canvas
        if selectedCanvas == nil {
            selectedCanvas = Canvas(context: viewContext)
            selectedCanvas!.id = UUID()
            selectedCanvas!.dateCreated = Date()
        }
        selectedCanvas!.title = name
        
        // Save the created canvas
        do {
            try viewContext.save()
            print("Canvas w/ name: \(self.name) saved.")
            showingInputSheet.toggle()
        } catch {
            print(error.localizedDescription)
        }
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
                Text(selectedCanvas == nil ? "Add Canvas" : "Save Changes")
            }
        }
        .onAppear(perform: populate)
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
                showingInputSheet: $showingInputSheet,
                selectedCanvas: .constant(nil)
            ).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
}
