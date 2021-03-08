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
    
    @Binding var showHostSheet: Bool
    
    // Binding variables for PKCanvasView
    @Binding var isDraw : Bool
    @Binding var isErase : Bool
    @Binding var color : Color
    @Binding var type : PKInkingTool.InkType
    
    // passed into PKDrawingView so that when it is toggled by the
    // back button, the view will update and save the current drawing
    @Binding var savingDrawing: Bool
    
    var body: some View {
        CanvasView(canvasId: canvas.id, height: canvasHeight, width: canvasWidth, isDraw: $isDraw, isErase: $isErase, color: $color, type: $type, savingDrawing: $savingDrawing)
            .frame(width: canvasWidth, height: canvasHeight)
            .navigationBarHidden(savingDrawing)
            .navigationBarTitle("\(canvas.wrappedTitle)")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(
                leading:
                    Button(action: {
                        savingDrawing.toggle()
                        self.presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left").font(.title2)
                    },
                trailing: HStack(spacing: 15) {
                    Button(action: { // pencil
                        isDraw = true
                        isErase = false
                        type = .pencil
                    }) {
                        Image(systemName: "pencil")
                            .foregroundColor(isDraw && type == .pencil ? .blue : .black)
                    }
                    
                    Button(action: { // pen
                        isDraw = true
                        isErase = false
                        type = .pen
                    }) {
                        Image(systemName: "pencil.tip")
                            .foregroundColor(isDraw && type == .pen ? .blue : .black)
                    }
                    
                    Button(action: { // marker
                        isDraw = true
                        isErase = false
                        type = .marker
                    }) {
                        Image(systemName: "highlighter")
                            .foregroundColor(isDraw && type == .marker ? .blue : .black)
                    }
                    
                    Button(action: { // eraser
                        isDraw = false
                        isErase = true
                    }) {
                        Image("erase_icon")
                            .resizable()
                            .frame(width: 35, height: 35)
                            .foregroundColor(isErase ? .blue : .black)
                    }
                    
                    Button(action: { // lasso cut tool
                        isDraw = false
                        isErase = false
                    }) {
                        Image(systemName: "scissors")
                            .font(.title2)
                            .foregroundColor(!isErase && !isDraw ? .blue : .black)
                    }
                    
                    ColorPicker("", selection: $color)
                    
                    Menu {
                        // TODO implement add canvas button after multiple canvases is implemented
                        Button(action: {
                            
                        }) { // Add canvas to session
                            Label {
                                Text("Add canvas")
                            } icon : {
                                Image(systemName: "rectangle")
                            }
                        }
                        
                        Button(action: {
                            showHostSheet.toggle()
                        }) { // Add terminal to session
                            Label {
                                Text("Add terminal")
                            } icon : {
                                Image(systemName: "greaterthan.square.fill")
                            }
                        }
                    } label : {
                        Image(systemName: "plus").font(.title)
                    }
                }
            )
    }
}

struct CanvasViewWithNavigation_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper()
    }
    
    struct PreviewWrapper: View {
        @State var showHostSheet: Bool = false
        @State var isDraw = true
        @State var isErase = false
        @State var color : Color = Color.black
        @State var type : PKInkingTool.InkType = .pencil
        @State var savingDrawing: Bool = false
        
        var body: some View {
            let context = PersistenceController.preview.container.viewContext
            
            let newCanvas = Canvas(context: context)
            newCanvas.id = UUID()
            newCanvas.dateCreated = Date()
            newCanvas.title = "Test Canvas"
            
            return CanvasViewWithNavigation(canvas: newCanvas, canvasHeight: UIScreen.main.bounds.height, canvasWidth: UIScreen.main.bounds.width, showHostSheet: $showHostSheet, isDraw: $isDraw, isErase: $isErase, color: $color, type: $type, savingDrawing: $savingDrawing).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
}
