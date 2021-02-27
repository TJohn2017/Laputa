//
//  CanvasView.swift
//  PencilKitProject
//
//  Created by Claire Mai on 2/21/21.
//

import SwiftUI

struct CanvasView: View {
    @GestureState var panState = CGSize.zero
    @State var viewState = CGSize.zero
    
    var pan: some Gesture {
        DragGesture()
            .updating($panState) { value, state, transaction in state = value.translation
                
            }
            .onEnded() { value in
                self.viewState.width += value.translation.width
                self.viewState.height += value.translation.height
            }
    }
    
    var body: some View {
        Rectangle()
            .frame(width: 100, height: 100)
            .offset(x: viewState.width + panState.width,
                    y: viewState.height + panState.height)
            .gesture(pan)
    }
}

struct CanvasView_Previews: PreviewProvider {
    static var previews: some View {
        CanvasView()
    }
}
