//
//  DrawingControls.swift
//  Laputa
//
//  Created by Cynthia Jia on 2/21/21.
//

import SwiftUI

struct DrawingControls: View {
    @Binding var color: Color
    @Binding var drawings: [Drawing]
    @Binding var lineWidth: CGFloat
    
    @State private var colorPickerShown = false

    private let spacing: CGFloat = 40
    
    var body: some View {
//        NavigationView {
//            VStack {
                HStack(spacing: spacing) {
//                    Button("Pick color") {
//                        self.colorPickerShown = true
//                    }
                    Button("Undo") {
                        if self.drawings.count > 0 {
                            self.drawings.removeLast()
                        }
                    }
                    .foregroundColor(Color.black)
                    Button("Clear") {
                        self.drawings = [Drawing]()
                    }
                    .foregroundColor(Color.black)
                }
//                HStack {
//                    Text("Pencil width")
//                        .padding()
//                    Slider(value: $lineWidth, in: 1.0...15.0, step: 1.0)
//                        .padding()
//                }
//            }
//        }
//        .frame(height: 50)
//        .sheet(isPresented: $colorPickerShown, onDismiss: {
//            self.colorPickerShown = false
////        }, content: { () -> ColorPicker in
////            ColorPicker(color: self.$color, colorPickerShown: self.$colorPickerShown)
////        })
    }
}

struct DrawingControls_Previews: PreviewProvider {
    static var previews: some View {
        DrawingControls(
            color: .constant(Color.black),
            drawings: .constant([]),
            lineWidth: .constant(3.0)
        )
    }
}
