//
//  InputCanvasView.swift
//  Laputa
//
//  Created by Daniel Guillen on 2/16/21.
//

import SwiftUI

struct InputCanvasView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @Binding var activeSheet: ActiveSheet?
    @Binding var parentActiveSheet: ActiveSheet?
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
            activeSheet = nil
            parentActiveSheet = nil
            try viewContext.save()
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

struct InputCanvasView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper()
    }
    
    struct PreviewWrapper: View {
        @State var activeSheet: ActiveSheet?
        @State var parentActiveSheet: ActiveSheet?

        var body: some View {
            
            return InputCanvasView(
                activeSheet: $activeSheet,
                parentActiveSheet: $parentActiveSheet,
                selectedCanvas: .constant(nil)
            ).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
}
