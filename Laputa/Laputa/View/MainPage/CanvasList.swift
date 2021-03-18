//
//  CanvasList.swift
//  Laputa
//
//  Created by Cynthia Jia on 3/6/21.
//

import SwiftUI

struct CanvasList: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @Binding var activeSheet: ActiveSheet?
    
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
        
        let columns = [
            GridItem(.flexible(minimum: 300, maximum: 500)),
            GridItem(.flexible(minimum: 300, maximum: 350))
            ]
        
        return ScrollView {
            Spacer().frame(height: 20)
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(canvases) { canvas in
                    HStack {
                        NavigationLink(
                            destination: SessionPageView(startCanvas: canvas)
                        ) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .frame(width: 300.0, height: 170.0)
                                    .padding()
                                    .foregroundColor(Color.white)
                                    .shadow(color: Color(white: 0, opacity: 0.3), radius: 4, x: -3, y: 3)
                                VStack {
                                    Text("\(canvas.wrappedTitle)")
                                        .font(.title)
                                        .foregroundColor(.black)
                                    Text("Created: \(dateFormatter.string(from: canvas.dateCreated))")
                                        .foregroundColor(Color.gray)
                                        .padding(2)
                                }.padding()
                            }
                        }
                        
                        Menu() {
                            Button("Open with a host", action: {
                                activeSheet = .selectHost
                                selectedCanvas = canvas
                            })
                            Button("Edit canvas", action: {
                                activeSheet = .inputSheet
                                selectedCanvas = canvas
                            })
                            Button("Delete canvas", action: {
                                deletedName = canvas.wrappedTitle
                                viewContext.delete(canvas)

                                do {
                                    try viewContext.save()
                                    showDeleteAlert.toggle()
                                } catch {
                                    print(error.localizedDescription)
                                }
                            })
                        } label: {
                            Label("", systemImage: "ellipsis.circle")
                                .font(.largeTitle)
                                .foregroundColor(.white)
                        }
                    }
                }
            }
        }
        .alert(isPresented: $showDeleteAlert) {
            Alert(
                title: Text("Canvas \"\(deletedName)\" deleted"),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}

struct CanvasList_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper()
    }
    
    struct PreviewWrapper: View {
        @State private var activeSheet: ActiveSheet?
        
        var body: some View {
            CanvasList(
                activeSheet: $activeSheet,
                selectedCanvas: .constant(nil)
            ).environment(
                \.managedObjectContext,
                PersistenceController.preview.container.viewContext
            )
        }
    }
}
