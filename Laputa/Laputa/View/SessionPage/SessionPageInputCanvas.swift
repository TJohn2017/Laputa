//
//  SessionPageInputCanvas.swift
//  Laputa
//
//  Created by Daniel Guillen on 2/21/21.
//

import SwiftUI

struct SessionPageInputCanvas: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        entity: Canvas.entity(),
        sortDescriptors: [NSSortDescriptor(key: "dateCreated", ascending: false)]
    )
    var canvases: FetchedResults<Canvas>
    
    @Binding var canvas: Canvas?
    @Binding var showCanvasSheet: Bool
    @State private var showingInputSheet: Bool = false
    
    var body: some View {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        
        return VStack {
            Text("Add a canvas in split view")
                .font(.title)
                .padding(.top, 50)
            ScrollView {
                VStack {
                    // Add a new canvas which will appear at the
                    // top of the list since it was most recently made
                    Button(action: {
                        showingInputSheet.toggle()
                    }) {
                        HStack {
                            Image(systemName: "plus.circle")
                            Text("New Canvas")
                        }
                        .font(.title)
                    }
                    .padding(50)
                    
                    // Choose from an existing canvas
                    ForEach(canvases) { canvas in
                        Button(action: {
                            self.canvas = canvas
                            showCanvasSheet.toggle()
                        }) {
                            VStack {
                                Text("\(canvas.wrappedTitle)")
                                    .frame(width: 400.0, height: 200.0)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(Color.black)
                                    .cornerRadius(10.0)
                                Text("Created: \(dateFormatter.string(from: canvas.wrappedDate))")
                                    .foregroundColor(Color.black)
                            }.padding()
                        }
                    }
                }
                .sheet(
                    isPresented: $showingInputSheet,
                    onDismiss: {
                        // TODO: Bring the user back to split view
                        // with newly created canvas showing
                    }
                ) {
                    MainPageInputCanvas(
                        showingInputSheet: $showingInputSheet,
                        selectedCanvas: .constant(nil)
                    )
                }
            }
        }
    }
}

struct SessionPageInputCanvas_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper()
    }
    
    struct PreviewWrapper: View {
        @State var canvas: Canvas?
        @State var showCanvasSheet: Bool = true
        
        var body: some View {
            
            return SessionPageInputCanvas(
                canvas: $canvas,
                showCanvasSheet: $showCanvasSheet
            ).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
}
