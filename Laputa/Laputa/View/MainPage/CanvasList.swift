//
//  CanvasList.swift
//  Laputa
//
//  Created by Cynthia Jia on 3/6/21.
//

import SwiftUI

struct CanvasList: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @Binding var showingInputSheet: Bool
    // passed up to MainPageView where editing canvas info sheet is located
    @Binding var selectedCanvas: Canvas?
    
    @State private var showDeleteAlert: Bool = false
    // store name of deleted canvas so it can be displayed to user
    @State var deletedName = ""
    
    @FetchRequest(
        entity: Canvas.entity(),
        sortDescriptors: [NSSortDescriptor(key: "dateCreated", ascending: false)]
    )
    var canvases: FetchedResults<Canvas>
    
    var body: some View {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        
        return VStack {
            ForEach(canvases) { canvas in
                HStack {
                    NavigationLink(
                        destination: SessionPageView(
                            hostPresent: true,
                            canvasPresent: false,
                            canvas: canvas
                        )) {
                        VStack {
                            Text("\(canvas.wrappedTitle)")
                                .frame(width: 400.0, height: 200.0)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(Color.black)
                                .cornerRadius(10.0)
                                .font(.largeTitle)
                            Text("Created: \(dateFormatter.string(from: canvas.wrappedDate))")
                                .foregroundColor(Color.white)
                        }.padding()
                    }
                    Menu() {
                        Button("Edit canvas", action: {
                            showingInputSheet.toggle()
                            selectedCanvas = canvas
                        })
                        Button("Delete canvas", action: {
                            deletedName = canvas.wrappedTitle
                            viewContext.delete(canvas)
                            
                            do {
                                try viewContext.save()
                                showDeleteAlert.toggle()
                                print("Canvas \"\(deletedName)\" deleted.")
                            } catch {
                                print(error.localizedDescription)
                            }
                        })
                    } label: {
                        Label("", systemImage: "ellipsis.circle")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                    }
                }.alert(isPresented: $showDeleteAlert) {
                    Alert(
                        title: Text("Canvas \"\(deletedName)\" deleted"),
                        dismissButton: .default(Text("OK"))
                    )
                }
            }
        }
    }
}

struct CanvasList_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper()
    }
    
    struct PreviewWrapper: View {
        @State private var showingInputSheet: Bool = false
        
        var body: some View {
            CanvasList(showingInputSheet: $showingInputSheet, selectedCanvas: .constant(nil)).environment(
                \.managedObjectContext,
                PersistenceController.preview.container.viewContext
            )
        }
    }
}
