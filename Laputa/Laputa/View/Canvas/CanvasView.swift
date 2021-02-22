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

    @State var isDrawing = false
    
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(entity: CodeCard.entity(), sortDescriptors: [])

    var cards: FetchedResults<CodeCard>
    
    // gesture for pinching to zoom in/out
    @State var magniScale = CGFloat(1.0)
    @GestureState var magnifyBy = CGFloat(1.0)
    
    // gesture to drag and move around
    @GestureState var panState = CGSize.zero
    @State var viewState = CGSize.zero
    
    func resetView() {
        magniScale = 1.0
        viewState = CGSize.zero
    }
    
    func setMaxZIndex() {
        if !cards.isEmpty {
            self.maxZIndex = cards[0].zIndex
        }
    }
    
    func toggleDrawing() {
        self.isDrawing = !self.isDrawing
    }
        
    @State var maxZIndex = 0.0
    var body: some View {
        // sets max canvas size to 2 * side length
        let canvasScale = CGFloat(2.0)
        let maxZoomIn = CGFloat(canvasScale)
        let maxZoomOut = CGFloat(1.0 / canvasScale)
        
        let sideLength = max(UIScreen.main.bounds.width, UIScreen.main.bounds.height) * canvasScale
        
        var magnification: some Gesture {
            MagnificationGesture()
                .updating($magnifyBy) { currentState, gestureState, transaction in
                    gestureState = currentState
                    
                    // magni + currentState - 1.0 is because
                    // maginfication gesture resets to scale 1.0 when you restart
                    magniScale = max(min(magniScale + currentState - 1.0, maxZoomIn), maxZoomOut)
                }
        }
        
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
        
        // TODO: bring selected card to front
        return ZStack() {
            ZStack() {
                Rectangle()
                    .frame(width: sideLength, height: sideLength, alignment: .center)
                    .foregroundColor(.red)
                    .zIndex(-2)
                Rectangle()
                    .frame(width: sideLength - 2, height: sideLength - 2, alignment: .center)
                    .foregroundColor(.white)
                    .zIndex(-1)
                ForEach(cards, id: \.self) { card in
                    CodeCardView(codeCard: card, maxZIndex: $maxZIndex)
                        .zIndex(card.zIndex)
                }
                DrawingView(isDrawing: self.isDrawing)
                    .allowsHitTesting(isDrawing)
                    .zIndex(maxZIndex + 1)
            }
            .scaleEffect(magniScale)
            .offset(
                x: viewState.width + panState.width,
                y: viewState.height + panState.height
            )
            .gesture(navigate)
        
            Button(action: resetView) {
                Text("Reset view")
            }
                .padding(8)
                .foregroundColor(.white)
                .font(.title)
                .background(Color.red)
                .cornerRadius(5.0)
                .offset(x: 0, y: -UIScreen.main.bounds.height / 2  + 30)
            Button(action: toggleDrawing) {
                Text("Drawing: \(isDrawing ? "On" : "Off")")
            }
                .padding(8)
                .foregroundColor(.white)
                .font(.title)
                .background(Color.black)
                .cornerRadius(5.0)
                .offset(x: UIScreen.main.bounds.width / 2 - 200, y: -UIScreen.main.bounds.height / 2  + 30)
        }
        .edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
        .onAppear(perform: setMaxZIndex)
    }
        
}

struct Canvas_Previews: PreviewProvider {
    static var previews: some View {
        CanvasView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
