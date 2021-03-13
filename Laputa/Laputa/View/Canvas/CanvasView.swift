//
//  CanvasView.swift
//  Laputa
//
//  Created by Cynthia Jia on 2/7/21.
//  Referred to
//  https://sarunw.com/posts/move-view-around-with-drag-gesture-in-swiftui/ and
//  https://developer.apple.com/documentation/swiftui/composing-swiftui-gestures
//  for reference
//

import SwiftUI
import PencilKit

struct CanvasView: View {
    
    // sets max canvas size to 2 * side length
    @State var canvasScale = CGFloat(2.0)
    @State var maxZoomIn = CGFloat(2.0)
    // allows user to zoom out to see entire canvas ( 1 / canvasScale)
    // and then a little more ( 0.2 )
    @State var maxZoomOut = CGFloat(1.0 / 2.0) - 0.2
    @State var isInDrawingMode = true
    
    @Environment(\.managedObjectContext) private var viewContext
    
    var fetchRequest: FetchRequest<Canvas>
    var canvasHeight: CGFloat
    var canvasWidth: CGFloat
    
    // Binding variables for PKCanvasView
    @Binding var pkCanvas: PKCanvasView
    @Binding var isDraw : Bool
    @Binding var isErase : Bool
    @Binding var color : Color
    @Binding var type : PKInkingTool.InkType
    
    // passed into PKDrawingView so that when it is toggled by the
    // back button, the view will update and save the current drawing
    @Binding var savingDrawing: Bool
    
    init(canvasId: UUID, height: CGFloat? = UIScreen.main.bounds.height, width: CGFloat? = UIScreen.main.bounds.width, pkCanvas: Binding<PKCanvasView>, isDraw: Binding<Bool>, isErase: Binding<Bool>, color : Binding<Color>, type : Binding<PKInkingTool.InkType>, savingDrawing: Binding<Bool>) {
        fetchRequest = FetchRequest<Canvas>(entity: Canvas.entity(), sortDescriptors: [], predicate: NSPredicate(format: "id == %@", canvasId as CVarArg))
        canvasHeight = height!
        canvasWidth = width!
        self._pkCanvas = pkCanvas
        self._isDraw = isDraw
        self._isErase = isErase
        self._color = color
        self._type = type
        self._savingDrawing = savingDrawing
    }
    
    var canvas: Canvas { fetchRequest.wrappedValue[0] }
    var cards: [CodeCard] { canvas.cardArray }
    
    // save how zoomed in the user is to CoreData
    func saveCanvasZoom() {
        viewContext.performAndWait {
            canvas.magnification = Double(magniScale)
            try? viewContext.save()
        }
    }
    
    // gesture for pinching to zoom in/out
    @State var magniScale = CGFloat(1.0)
    var magnification: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                // smaller = less sensitive, larger = more
                let sensitivity = CGFloat(0.05)
                // magni + currentState - 1.0 is because
                // maginfication gesture resets to scale 1.0 when you restart
                let magni = (value - 1.0) * sensitivity + magniScale
                // clamp it
                magniScale = max(min(magni, maxZoomIn), maxZoomOut)
                
                saveCanvasZoom()
            }
    }
    
    // saves user's location on canvas to CoreData
    func saveCanvasPosition() {
        viewContext.performAndWait {
            canvas.locX = Double(viewState.width)
            canvas.locY = Double(viewState.height)
            try? viewContext.save()
        }
    }
    
    // gesture to drag and move around
    @GestureState var panState = CGSize.zero
    @State var viewState = CGSize.zero
    var pan: some Gesture {
        DragGesture()
            .updating($panState) { value, state, transaction in
                state = value.translation
            }
            .onEnded() { value in
                self.viewState.width += value.translation.width
                self.viewState.height += value.translation.height
                
                saveCanvasPosition()
            }
    }
    
    // TODO: figure out if this exclusive part is actually working
    // combines pan and magnification so that if we try to do both, only
    // panning will work.
    var navigate: some Gesture {
        pan.exclusively(before: magnification)
    }
    
    // In case the user gets lost when navigating around,
    // this will reset to their initial view.
    func resetView() {
        magniScale = 1.0
        viewState = CGSize.zero
        saveCanvasPosition()
        saveCanvasZoom()
    }
    
    func toggleDrawing() {
        self.isInDrawingMode.toggle()
    }
    
    // Since cards are returned sorted by zIndex, this gets
    // the highest zIndex from all cards.
    @State var maxZIndex = 0.0
    
    // Set maxZindex, saved magnification, and saved position
    func setup() {
        if !cards.isEmpty {
            self.maxZIndex = cards[0].zIndex
        }
        
        magniScale = CGFloat(canvas.wrappedMagnification)
        viewState.width = CGFloat(canvas.locX)
        viewState.height = CGFloat(canvas.locY)
    }
    
    var body: some View {
        
        let sideLength = max(canvasWidth, canvasHeight) * canvasScale
        
        return
            ZStack() {
                ZStack() {
                    // White canvas with a thin border to show edges.
                    // Square to avoid losing info when rotated.
                    Rectangle()
                        .frame(width: sideLength, height: sideLength, alignment: .center)
                        .foregroundColor(.white)
                        .zIndex(-1)
                    ForEach(canvas.cardArray) { card in
                        CodeCardView(codeCard: card, maxZIndex: $maxZIndex)
                    }
                    PKDrawingView(
                        pkCanvas: $pkCanvas,
                        isDraw: $isDraw,
                        isErase: $isErase,
                        color: $color,
                        type: $type,
                        isInDrawingMode: $isInDrawingMode,
                        canvasId: canvas.id,
                        savingDrawing: $savingDrawing
                    )
                        .background(Color.white.opacity(0.01))
                        .zIndex(maxZIndex + 1)
                        .allowsHitTesting(isInDrawingMode)
                }
                // if we're saving the drawing/exiting, zoom to 0 so that
                // the large canvas overhang doesn't mess up the exit animation
                .scaleEffect(savingDrawing ? 0.0 : CGFloat(canvas.wrappedMagnification))
                .offset(
                    x: CGFloat(canvas.locX) + panState.width,
                    y: CGFloat(canvas.locY) + panState.height
                )
                .gesture(navigate)
                .onTapGesture (count: 2, perform: {
                    isInDrawingMode.toggle()
                })
               

                Button(action: resetView) {
                    Image(systemName: "scope")
                        .padding(10)
                        .font(.title)
                        .foregroundColor(Color.white)
                        .background(Color.red)
                }
                .cornerRadius(20)
                .offset(
                    x: canvasWidth / 2 - 70,
                    y: -canvasHeight / 2  + 150
                )
                Button(action: toggleDrawing) {
                    isInDrawingMode ?
                        Image(systemName: "pencil")
                        .padding()
                        .font(.title)
                        .foregroundColor(Color.white)
                        .background(Color.black)
                        :
                        Image(systemName: "pencil.slash")
                        .padding()
                        .font(.title)
                        .foregroundColor(Color.white)
                        .background(Color.black)
                }
                .cornerRadius(20)
                .offset(
                    x: canvasWidth / 2 - 70,
                    y: -canvasHeight / 2  + 70
                )
            }
            .onAppear(perform: setup)
    }
}



struct Canvas_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PreviewWrapper()
        }
    }
    
    struct PreviewWrapper: View {
        @State var pkCanvas = PKCanvasView()
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
            
            return CanvasView(canvasId: newCanvas.id, pkCanvas: $pkCanvas, isDraw : $isDraw, isErase : $isErase, color : $color, type: $type, savingDrawing: $savingDrawing).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
}
