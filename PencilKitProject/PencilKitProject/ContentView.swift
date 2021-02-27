//
//  ContentView.swift
//  PencilKitProject
//
//  Created by Claire Mai on 2/20/21.
//

import SwiftUI
import PencilKit

struct ContentView: View {
    var body: some View {
        NavigationView {
            ZStack {
                CanvasView()
                CanvasView()
                CanvasView()
                Home()//.allowsHitTesting(false)
            }
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct Home: View {
    @State var canvas = PKCanvasView()
    @State var isDraw = true
    @State var isErase = false
    @State var color : Color = .black
    @State var type : PKInkingTool.InkType = .pencil
    @State var colorPicker = false
    
    var body: some View {
        
        // navigate to drawing view
        DrawingView(canvas: $canvas, isDraw: $isDraw, isErase: $isErase, type : $type, color : $color)
            .navigationTitle("Drawing")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: Button(action: {
                    // saving Image
                    
            }, label: {
                Image(systemName: "square.and.arrow.down.fill").font(.title)
            }), trailing: HStack(spacing: 15) {
                Button(action: {
                    // erase tool
                    isDraw = false
                    isErase = true
                }) {
                    Image(systemName: "pencil.slash").font(.title)
                }
                Button(action: {
                    // cut tool
                    isDraw = false
                    isErase = false
                }) {
                    Image(systemName: "lasso").font(.title)
                }
                // Menu for ink type and color
                Menu {
                    Button(action: {
                        colorPicker.toggle()
                    }) {
                        Label {
                            Text("Color")
                        } icon: {
                            Image(systemName: "eyedropper.full")
                        }
                    }
                    
                    // Pencil button
                    Button(action: {
                        // changing type
                        isDraw = true
                        type = .pencil
                    }) {
                        Label {
                            Text ("Pencil")
                        } icon: {
                            Image(systemName: "pencil")
                        }
                    }
                    
                    Button(action: {
                        isDraw = true
                        type = .pen
                    }) {
                        Label {
                            Text ("Pen")
                        } icon: {
                            Image(systemName: "pencil.tip")
                        }
                    }
                    
                    Button(action: {
                        isDraw = true
                        type = .marker
                    }) {
                        Label {
                            Text ("Marker")
                        } icon: {
                            Image(systemName: "highlighter")
                        }
                    }
                    
                } label: {
                    Text("Tools")
                }
            })
            .sheet(isPresented: $colorPicker) {
                ColorPicker("Pick Color", selection: $color)
                    .padding()
            }
    }
    
}

struct DrawingView : UIViewRepresentable {
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
