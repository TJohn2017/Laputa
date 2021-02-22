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
        sortDescriptors: []
    )
    var canvases: FetchedResults<Canvas>
    
    @State var canvas: Canvas?
    @Binding var showCanvasSheet: Bool
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(canvases) { elem in
                    Button(action: {
                        self.canvas = elem
                        showCanvasSheet.toggle()
                    }) {
                        Text("Canvas \(elem.id)")
                            .font(.title)
                            .fontWeight(.regular)
                            .frame(width: 400.0, height: 200.0)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(Color.black)
                            .cornerRadius(10.0)
                    }
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
                canvas: canvas,
                showCanvasSheet: $showCanvasSheet
            ).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
}
