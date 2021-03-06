//
//  SessionPageView.swift
//  Laputa
//
//  Created by Daniel Guillen on 2/20/21.
//

import SwiftUI
import UIKit
import PencilKit

struct SessionPageView: View {
    @State var hostPresent: Bool
    @State var canvasPresent: Bool
    @State var host: Host?
    @State var canvas: Canvas?
    @State var showCanvasSheet: Bool = false
    @State var showHostSheet: Bool = false
    // State vars for PKDrawingView
    @State var isDraw = true
    @State var isErase = false
    @State var color : Color = Color.black
    @State var type : PKInkingTool.InkType = .pencil
    
    
    var body: some View {
        // return terminal view only
        if (host != nil && canvas == nil) {
            // Case: a terminal-only session.
            // TODO: need to be able to handle incorrect / malformed host info.
            let host_info = HostInfo(
                alias:host!.name!,
                hostname:host!.host!,
                username:host!.username!,
                usePassword:true,
                password:host!.password!
            )
            
            return AnyView(
                ZStack {
                    Color.black
                    SwiftUITerminal(host: host_info, canvas: $canvas, modifyTerminalHeight: false)
                }
                .navigationBarTitle("\(host!.name!)")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(trailing:
                        Menu {
                            Button(action: {
                                // TODO stop this if we already added a canvas
                                showCanvasSheet.toggle()
                            }) { // Add canvas to session
                                Label {
                                    Text("Add canvas")
                                } icon : {
                                    Image(systemName: "rectangle")
                                }
                            }
                            
                            Button(action: {
                                // TODO toggle show terminal sheet
                                // can only be implemented after multiple terminals is implemented
                            }) { // Add terminal to session
                                Label {
                                    Text("Add terminal")
                                } icon : {
                                    Image(systemName: "greaterthan.square.fill")
                                }
                            }
                        } label : {
                            Image(systemName: "plus").font(.title)
                        })
                .edgesIgnoringSafeArea(.top)  //TODO not sure why this is here
                .sheet(
                    isPresented: $showCanvasSheet
                ) {
                    SessionPageInputCanvas(canvas: $canvas, showCanvasSheet: $showCanvasSheet)
                }
            )
            // return canvas view only
        } else if (host == nil && canvas != nil) {
            // Case: a canvas-only session.
            return AnyView(
                GeometryReader { geometry in
                    ZStack {
                        Color.black
                        CanvasView(canvasId: canvas!.id, isSplitView: false, height: geometry.size.height, width: geometry.size.width, isDraw: $isDraw, isErase: $isErase, color: $color, type: $type)
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .navigationBarTitle("\(canvas!.wrappedTitle)")
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationBarItems(trailing: HStack(spacing: 15) {
                            Button(action: { // pencil
                                isDraw = true
                                type = .pencil
                            }) {
                                Image(systemName: "pencil")
                            }
                            
                            Button(action: { // pen
                                isDraw = true
                                type = .pen
                            }) {
                                Image(systemName: "pencil.tip")
                            }
                            
                            Button(action: { // marker
                                isDraw = true
                                type = .marker
                            }) {
                                Image(systemName: "highlighter")
                            }
                            
                            Button(action: { // eraser
                                isDraw = false
                                isErase = true
                            }) {
                                Image(systemName: "pencil.slash").font(.title)
                            }
                            
                            Button(action: { // lasso cut tool
                                isDraw = false
                                isErase = false
                            }) {
                                Image(systemName: "scissors").font(.title)
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
                    .sheet(
                        isPresented: $showHostSheet
                    ) {
                        SessionPageInputHost(host: $host, showHostSheet: $showHostSheet)
                    }
                }
            )
        } else {
            // Case: a canvas-and-terminal session.
            let host_info = HostInfo(
                alias:host!.name!,
                hostname:host!.host!,
                username:host!.username!,
                usePassword:true,
                password:host!.password!
            )
            
            return AnyView(
                GeometryReader { geometry in
                    VStack {
                        CanvasView(canvasId: canvas!.id, isSplitView: true, height: geometry.size.height / 2, isDraw: $isDraw, isErase: $isErase, color: $color, type: $type)
                            .frame(width: geometry.size.width, height: geometry.size.height / 2)
                            .navigationBarTitle("\(host!.name!) / \(canvas!.wrappedTitle)")
                            .navigationBarTitleDisplayMode(.inline)
                            .navigationBarItems(trailing: HStack(spacing: 15) {
                                    Button(action: { // pencil
                                        isDraw = true
                                        type = .pencil
                                    }) {
                                        Image(systemName: "pencil")
                                    }
                                    
                                    Button(action: { // pen
                                        isDraw = true
                                        type = .pen
                                    }) {
                                        Image(systemName: "pencil.tip")
                                    }
                                    
                                    Button(action: { // marker
                                        isDraw = true
                                        type = .marker
                                    }) {
                                        Image(systemName: "highlighter")
                                    }
                                    
                                    Button(action: { // eraser
                                        isDraw = false
                                        isErase = true
                                    }) {
                                        Image(systemName: "pencil.slash").font(.title)
                                    }
                                    
                                    Button(action: { // lasso cut tool
                                        isDraw = false
                                        isErase = false
                                    }) {
                                        Image(systemName: "scissors").font(.title)
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
                                        
                                        // TODO implement add terminal button after multiple terminals is implemented
                                        Button(action: {}) { // Add terminal to session
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
                        // Terminal view
                        SwiftUITerminal(host: host_info, canvas: $canvas, modifyTerminalHeight: true)
                            .frame(width: geometry.size.width, height: geometry.size.height / 2)
                    }
                }
            )
        }
    }
}



struct SessionPageView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper()
    }
    
    struct PreviewWrapper: View {
        
        var body: some View {
            let context = PersistenceController.preview.container.viewContext
            
            /*
             let newHost = Host(context: context)
             newHost.host = "host_1"
             newHost.name = "Name #1"
             newHost.password = "password_1"
             newHost.port = "22"
             newHost.username = "username_1"
             */
            
            let newHost = Host(context: context)
            newHost.name = "Laputa"
            newHost.host = "159.65.78.184"
            newHost.username = "laputa"
            newHost.port = "22"
            newHost.password = "LaputaIsAwesome"
            
            let newCanvas = Canvas(context: context)
            newCanvas.id = UUID()
            newCanvas.dateCreated = Date()
            newCanvas.title = "Test Canvas"
            
            return SessionPageView(
                hostPresent: true,
                canvasPresent: true,
                host: newHost,
                canvas: newCanvas
            ).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
}
