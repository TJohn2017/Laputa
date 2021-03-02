//
//  DrawingView.swift
//  Laputa
//
//  Created by Cynthia Jia on 2/21/21.
//

import SwiftUI

struct DrawingView: View {
    @State private var currentDrawing: Drawing = Drawing()
    @State private var drawings: [Drawing] = [Drawing]()
    @State private var color: Color = Color.black
    @State private var lineWidth: CGFloat = 3.0
    
    var isDrawing: Bool
    
    var body: some View {
        ZStack{
            VStack(alignment: .center) {
                DrawingPad(currentDrawing: $currentDrawing,
                           drawings: $drawings,
                           color: $color,
                           lineWidth: $lineWidth,
                           isDrawing: isDrawing)
//                DrawingControls(color: $color, drawings: $drawings, lineWidth: $lineWidth)
            }
        }
    }
}

struct DrawingView_Previews: PreviewProvider {
    static var previews: some View {
        DrawingView(isDrawing: true)
    }
}
