//
//  PencilKitDrawingView.swift
//  Laputa
//
//  Created by Claire Mai on 2/26/21.
//

import SwiftUI
import PencilKit
import UIKit


struct PKDrawingView: View {
    @State var canvas = PKCanvasView()
    
    @Binding var isDraw : Bool
    @Binding var isErase : Bool
    @Binding var color : Color
    @Binding var type : PKInkingTool.InkType
    @Binding var isInDrawingMode : Bool
    var canvasId : UUID
    
    // passed down so that when it is toggled with the back button,
    // the view will update and the current drawing will be saved
    @Binding var savingDrawing: Bool
    
    var body: some View {
        PencilKitView(canvas: $canvas, isDraw: $isDraw, isErase: $isErase, type: $type, color: $color, isInDrawingMode: $isInDrawingMode, canvasId: canvasId, savingDrawing: $savingDrawing)
    }
}

struct PencilKitView : UIViewRepresentable {
    
    @Environment(\.managedObjectContext) private var viewContext
    
    // Used to capture drawing for saving into albums
    @Binding var canvas : PKCanvasView
    @Binding var isDraw : Bool
    @Binding var isErase : Bool
    @Binding var type : PKInkingTool.InkType
    @Binding var color : Color
    @Binding var isInDrawingMode : Bool
    
    @Binding var savingDrawing: Bool
    
    var fetchRequest: FetchRequest<Canvas>
    init(canvas: Binding<PKCanvasView>, isDraw: Binding<Bool>, isErase: Binding<Bool>, type: Binding<PKInkingTool.InkType>, color: Binding<Color>, isInDrawingMode: Binding<Bool>, canvasId: UUID, savingDrawing: Binding<Bool>) {
        
        fetchRequest = FetchRequest<Canvas>(entity: Canvas.entity(), sortDescriptors: [], predicate: NSPredicate(format: "id == %@", canvasId as CVarArg))
        
        self._canvas = canvas
        self._isDraw = isDraw
        self._isErase = isErase
        self._color = color
        self._type = type
        self._isInDrawingMode = isInDrawingMode
        self._savingDrawing = savingDrawing
    }
    var canvasEntity: Canvas { fetchRequest.wrappedValue[0] }
    
    // updating inkType
    var ink : PKInkingTool {
        PKInkingTool(type, color: UIColor(color))
    }
    let eraser = PKEraserTool(.bitmap)
    let cut = PKLassoTool()
    
    
    func makeUIView(context: Context) -> PKCanvasView {
        // try pulling saved drawings from CoreData
        if (canvasEntity.drawingData != nil) {
            do {
                try canvas.drawing = PKDrawing.init(data: canvasEntity.drawingData!)
            } catch {
                print("Error loading drawing object")
            }
        }
        
        canvas.backgroundColor = .clear
        canvas.isOpaque = false
        
        if (isDraw) {
            canvas.tool = ink
        } else if (isErase) {
            canvas.tool =  eraser
        } else { // isCut
            canvas.tool =  cut
        }

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
        
        // save updated drawing in CoreData
        viewContext.performAndWait {
            canvasEntity.drawingData = uiView.drawing.dataRepresentation()
            try? viewContext.save()
        }
    }
}

