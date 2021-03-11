//
//  SelectCanvasView.swift
//  Laputa
//
//  Created by Daniel Guillen on 2/21/21.
//
//  A list of canvases for when the user wants to select a canvas to use
//  in tandem with an already selected host.
// 

import SwiftUI

struct SelectCanvasView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        entity: Canvas.entity(),
        sortDescriptors: [NSSortDescriptor(key: "dateCreated", ascending: false)]
    )
    var canvases: FetchedResults<Canvas>
    
    // the selected host that the user wants to use with a canvas
    @Binding var selectedHost: Host?
    // the canvas that the user eventually selects from this view
    @Binding var selectedCanvas: Canvas?
    // If we're coming from the main page, whether or not navigation
    // to session page behind sheet should be activated
    @Binding var navToSessionActive: Bool
    // keeps track of the active state of this sheet
    @Binding var activeSheet: ActiveSheet?
    // keeps track of the active state of a new input sheet when user wants to create a new canvas
    @State var activeInputSheet: ActiveSheet?
        
    var body: some View {
        let columns = [
            GridItem(.flexible(minimum: 250, maximum: 300)),
            GridItem(.flexible(minimum: 250, maximum: 300))
        ]
        
        return
            ZStack {
                Color("CanvasMain")
                VStack {
                    (Text("Choose a canvas to use with ") + Text("\(selectedHost!.name)").bold())
                        .foregroundColor(.white)
                        .font(.largeTitle)
                        .padding(.top, 50)
                    
                    // Add a new canvas
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
                                Text("New Canvas")
                                    .bold()
                            }
                            .font(.title)
                            .foregroundColor(Color("CanvasMain"))
                        }
                        
                    }
                    .padding(.bottom, 30)
                    
                    // Choose from an existing canvas
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(canvases) { canvas in
                                Button(action: {
                                    selectedCanvas = canvas
                                    navToSessionActive.toggle()
                                    activeSheet = nil
                                }) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 10)
                                            .frame(width: 250.0, height: 150.0)
                                            .padding()
                                            .foregroundColor(Color.white)
                                            .shadow(color: Color(white: 0, opacity: 0.3), radius: 4, x: -3, y: 3)
                                        VStack {
                                            Text("\(canvas.wrappedTitle)")
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
                                    navToSessionActive.toggle()
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

struct SelectCanvasView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper()
    }
    
    struct PreviewWrapper: View {
        @State var navToSessionActive: Bool = false
        @State var canvas: Canvas?
        @State var showCanvasSheet: Bool = true
        @State var activeSheet: ActiveSheet?
        
        var body: some View {
            let context = PersistenceController.preview.container.viewContext
            
            let host = Host(context: context)
            host.name = "Laputa"
            
            return SelectCanvasView(
                selectedHost: .constant(host),
                selectedCanvas: $canvas,
                navToSessionActive: $navToSessionActive,
                activeSheet: $activeSheet
            ).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
}
