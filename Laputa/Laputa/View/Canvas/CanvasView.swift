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

struct CanvasView: View {
    
    // sets max canvas size to 2 * side length
    @State var canvasScale = CGFloat(1.0)
    @State var maxZoomIn = CGFloat(1.0)
    @State var maxZoomOut = CGFloat(1.0 / 1.0)
    
    @State var isDrawing = false
    @Environment(\.managedObjectContext) private var viewContext
    
    @Environment(\.verticalSizeClass) var vSizeClass
    @Environment(\.horizontalSizeClass) var hSizeClass
    
    var fetchRequest: FetchRequest<Canvas>
    var isSplit: Bool
    var canvasHeight: CGFloat
    var canvasWidth: CGFloat
    init(canvasId: UUID, isSplitView: Bool, height: CGFloat? = UIScreen.main.bounds.height, width: CGFloat? = UIScreen.main.bounds.width) {
        fetchRequest = FetchRequest<Canvas>(entity: Canvas.entity(), sortDescriptors: [], predicate: NSPredicate(format: "id == %@", canvasId as CVarArg))
        isSplit = isSplitView
        canvasHeight = height!
        canvasWidth = width!
    }
    var canvas: Canvas { fetchRequest.wrappedValue[0] }
    var cards: [CodeCard] { canvas.cardArray }
    
    
    // gesture for pinching to zoom in/out
    @State var magniScale = CGFloat(1.0)
    @GestureState var magnifyBy = CGFloat(1.0)
    var magnification: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                // magni + currentState - 1.0 is because
                // maginfication gesture resets to scale 1.0 when you restart
                magniScale = max(min(magniScale + value - 1.0, maxZoomIn), maxZoomOut)
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
            }
    }
    
    // TODO: figure out if this exclusive part is actually working
    // combines pan and magnification so that if we try to do both, only
    // panning will work.
    var navigate: some Gesture {
        pan.exclusively(before: magnification)
    }
    
    func resetView() {
        magniScale = 1.0
        viewState = CGSize.zero
        print("vertical size class: \(vSizeClass == .compact ? "Compact" : "Regular")")
        print("horizontal size class: \(hSizeClass == .compact ? "Compact" : "Regular")")
    }
    
    func toggleDrawing() {
        self.isDrawing = !self.isDrawing
    }
    
    @State var maxZIndex = 0.0
    func setMaxZIndex() {
        if !cards.isEmpty {
            self.maxZIndex = cards[0].zIndex
        }
    }
    
    var body: some View {
        
        let sideLength = max(UIScreen.main.bounds.width, UIScreen.main.bounds.height) * canvasScale
        
        return
            ZStack() {
                ZStack() {
                    Rectangle()
                        .frame(width: sideLength, height: sideLength, alignment: .bottom)
                        .foregroundColor(.red)
                        .zIndex(-2)
                    Rectangle()
                        .frame(width: sideLength - 2, height: sideLength - 2, alignment: .center)
                        .foregroundColor(.white)
                        .zIndex(-1)
                    ForEach(canvas.cardArray) { card in
                        CodeCardView(codeCard: card, maxZIndex: $maxZIndex)
                    }
                    DrawingView(isDrawing: self.isDrawing)
                        .allowsHitTesting(isDrawing)
                        .zIndex(maxZIndex + 1)
                    Text("UI height: \(UIScreen.main.bounds.height), UI width: \(UIScreen.main.bounds.width)")
                }
                .scaleEffect(magniScale)
                .offset(
                    x: viewState.width + panState.width,
                    y: viewState.height + panState.height
                )
                .gesture(navigate)
                
                Button(action: resetView) {
                    Image(systemName: "scope")
                        .padding(10)
                        .font(.largeTitle)
                        .foregroundColor(Color.white)
                        .background(Color.red)
                }
                .clipShape(Circle())
                .offset(
                    x: canvasWidth / 2 - 70,
                    y: -canvasHeight / 2  + 150
                )
                Button(action: toggleDrawing) {
                    isDrawing ?
                        Image(systemName: "pencil.slash")
                        .padding()
                        .font(.largeTitle)
                        .foregroundColor(Color.white)
                        .background(Color.black)
                        :
                        Image(systemName: "pencil")
                        .padding()
                        .font(.largeTitle)
                        .foregroundColor(Color.white)
                        .background(Color.black)
                }
                .clipShape(Circle())
                .offset(
                    x: canvasWidth / 2 - 70,
                    y: -canvasHeight / 2  + 70
                )
            }
            .onAppear(perform: setMaxZIndex)
            .coordinateSpace(name: "Global")
    }
}



struct Canvas_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PreviewWrapper()
        }
    }
    
    struct PreviewWrapper: View {
        var body: some View {
            let context = PersistenceController.preview.container.viewContext
            let newCanvas = Canvas(context: context)
            newCanvas.id = UUID()
            newCanvas.dateCreated = Date()
            
            return CanvasView(canvasId: newCanvas.id, isSplitView: false).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
}
