//
//  AddCanvasView.swift
//  Laputa
//
//  Created by Daniel Guillen on 3/12/21.
//

import SwiftUI

struct AddCanvasView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        entity: Canvas.entity(),
        sortDescriptors: [NSSortDescriptor(key: "dateCreated", ascending: false)]
    )
    var fetchedCanvases: FetchedResults<Canvas>
    
    @Binding var canvas: Canvas?
    
    // TODO: selectedCanvases to be used in the event of multiple canvas
    // functionality.
    // The array of canvases that the user eventually appends to from this view.
    @Binding var selectedCanvases: [Canvas?]
    
    // Keeps track of the active state of this sheet.
    @Binding var activeSheet: ActiveSheet?
    // Keeps track of the active state of a new input sheet when user wants to create a
    // new canvas
    @State var activeInputSheet: ActiveSheet?
    // Variable to pass to the input sheet if the user wants to create a new canvas.
    @State var selectedCanvas: Canvas?
    
    var body: some View {
        let columns = [
            GridItem(.flexible(minimum: 250, maximum: 300)),
            GridItem(.flexible(minimum: 250, maximum: 300))
        ]

        return
            ZStack {
                Color("CanvasMain")
                VStack {
                    Text("Choose a canvas to add")
                        .foregroundColor(.white)
                        .font(.largeTitle)
                        .padding(.top, 50)
                    
                    // Add a new canvas.
                    ZStack {
                        RoundedRectangle(cornerRadius: 30)
                            .frame(width: 240, height: 50)
                            .foregroundColor(Color.white)
                        Button(action: {
                            activeInputSheet = .inputSheet
                            selectedCanvas = nil
                        }) {
                            HStack {
                                Image(systemName: "plus.circle")
                                Text("New Canvas").bold()
                            }
                            .font(.title)
                            .foregroundColor(Color("CanvasMain"))
                        }
                    }
                    .padding(.bottom, 30)
                    
                    // Choose from an existing canvas.
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(fetchedCanvases) { canvasElem in
                                Button(action: {
                                    // TODO: in the event of multiple canvas functionality,
                                    //       append to canvases array.
                                    canvas = canvasElem
                                    activeSheet = nil
                                }) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 10)
                                            .frame(width: 250.0, height: 150.0)
                                            .padding()
                                            .foregroundColor(Color.white)
                                            .shadow(
                                                color: Color(white: 0, opacity: 0.3),
                                                radius: 3,
                                                x: -3,
                                                y: 3
                                            )
                                        VStack {
                                            Text("\(canvasElem.wrappedTitle)")
                                                .font(.title)
                                                .foregroundColor(.black)
                                        }.padding()
                                    }
                                }
                            }
                        }
                        .sheet(
                            item: $activeInputSheet,
                            onDismiss: {
                                if selectedCanvas != nil {
                                    // TODO: in the event of multiple canvas functionality,
                                    //       append selectedCanvas to canvases array.
                                    canvas = selectedCanvas!
                                }
                            }
                        ) { item in
                            InputCanvasView(
                                activeSheet: $activeInputSheet,
                                parentActiveSheet: $activeSheet,
                                selectedCanvas: $selectedCanvas
                            )
                        }
                    }
                }
            }
    }
}

struct AddCanvasView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper()
    }
    
    struct PreviewWrapper: View {
        @State var canvas: Canvas?
        @State var selectedCanvases: [Canvas?] = [Canvas?]()
        @State var activeSheet: ActiveSheet?
        
        var body: some View {
            return AddCanvasView(
                canvas: $canvas,
                selectedCanvases: $selectedCanvases,
                activeSheet: $activeSheet
            )
            .environment(
                \.managedObjectContext,
                PersistenceController.preview.container.viewContext
            )
        }
    }
}
