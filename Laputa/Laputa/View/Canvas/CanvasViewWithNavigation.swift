//
//  CanvasViewWithNavigation.swift
//  Laputa
//
//  Created by Cynthia Jia on 3/7/21.
//

import SwiftUI
import PencilKit

struct CanvasViewWithNavigation: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var canvas: Canvas
    var canvasHeight: CGFloat
    var canvasWidth: CGFloat
    
    @Binding var activeSheet: ActiveSheet?
    
    // Binding variables for PKCanvasView
    @Binding var isDraw : Bool
    @Binding var isErase : Bool
    @Binding var color : Color
    @Binding var type : PKInkingTool.InkType
    
    
    // Passed into PKDrawingView so that when it is toggled by the
    // back button, the view will update and save the current drawing.
    @Binding var savingDrawing: Bool
    
    @Binding var session : SSHConnection?
    
    var body: some View {
        CanvasView(
            canvasId: canvas.id,
            height: canvasHeight,
            width: canvasWidth,
            isDraw: $isDraw,
            isErase: $isErase,
            color: $color,
            type: $type,
            savingDrawing: $savingDrawing
        )
        .frame(width: canvasWidth, height: canvasHeight)
    }
}

struct CanvasViewWithNavigation_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper()
    }
    
    struct PreviewWrapper: View {
        @State var activeSheet: ActiveSheet?
        @State var isDraw = true
        @State var isErase = false
        @State var color : Color = Color.black
        @State var type : PKInkingTool.InkType = .pencil
        @State var savingDrawing: Bool = false
        @State var session : SSHConnection?
        
        var body: some View {
            let context = PersistenceController.preview.container.viewContext
            
            let newCanvas = Canvas(context: context)
            newCanvas.id = UUID()
            newCanvas.dateCreated = Date()
            newCanvas.title = "Test Canvas"
            
            return CanvasViewWithNavigation(canvas: newCanvas, canvasHeight: UIScreen.main.bounds.height, canvasWidth: UIScreen.main.bounds.width, activeSheet: $activeSheet, isDraw: $isDraw, isErase: $isErase, color: $color, type: $type, savingDrawing: $savingDrawing, session: $session).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
}
