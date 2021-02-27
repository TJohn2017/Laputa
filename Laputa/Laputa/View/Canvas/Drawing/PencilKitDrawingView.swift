//
//  PencilKitDrawingView.swift
//  Laputa
//
//  Created by Claire Mai on 2/26/21.
//

import SwiftUI
import PencilKit


struct PKDrawingView: View {
    @State var canvas = PKCanvasView()

    @Binding var isDraw : Bool
    @Binding var isErase : Bool
    @Binding var color : Color
    @Binding var type : PKInkingTool.InkType
    
    var body: some View {
        NavigationView {
            PencilKitView(canvas: $canvas, isDraw: $isDraw, isErase: $isErase, type: $type, color: $color)
                .navigationTitle("Drawing Pad")
                .navigationBarTitleDisplayMode(.inline)
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}

struct PencilKitView : UIViewRepresentable {
    // Used to capture drawing for saving into albums
    @Binding var canvas : PKCanvasView
    @Binding var isDraw : Bool
    @Binding var isErase : Bool
    @Binding var type : PKInkingTool.InkType
    @Binding var color : Color
    
    // updating inkType
    var ink : PKInkingTool {
        PKInkingTool(type, color: UIColor(color))
    }
    let eraser = PKEraserTool(.bitmap)
    let cut = PKLassoTool()
    
    func makeUIView(context: Context) -> PKCanvasView {
        canvas.drawingPolicy = .anyInput
        canvas.backgroundColor = .clear
        canvas.isOpaque = false
        if (isDraw) {
            canvas.tool = ink
        } else if (isErase) {
            canvas.tool =  eraser
        } else { // isCut
            canvas.tool =  cut
        }
        canvas.backgroundColor = .clear
        canvas.isOpaque = false
        return canvas
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        // update tool whenever main view updates
        if (isDraw) {
            uiView.tool = ink
        } else if (isErase) {
            uiView.tool =  eraser
        } else { // lasso tool for cutting
            uiView.tool =  cut
        }
    }
}

