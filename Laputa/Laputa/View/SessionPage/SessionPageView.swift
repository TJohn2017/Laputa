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
    @State var host: Host?
    @State var canvas: Canvas?
    @State var session: SSHConnection?
    @State var showCanvasSheet: Bool = false
    @State var showHostSheet: Bool = false
    // State vars for PKDrawingView
    @State var isDraw = true
    @State var isErase = false
    @State var color : Color = Color.black
    @State var type : PKInkingTool.InkType = .pencil
    
    // passed into CanvasView/PKDrawingView so that when it is toggled by the
    // back button, the view will update and save the current drawing
    @State var savingDrawing = false
    
    var body: some View {
        // Setup host info and ssh connection if we are going to be displaying a terminal
        var host_info: HostInfo? = nil
        if (host != nil) {
            host_info = HostInfo(
                alias: host!.name,
                username: host!.username,
                hostname: host!.host,
                authType: host!.authenticationType,
                password: host!.password,
                publicKey: host!.publicKey,
                privateKey: host!.privateKey,
                privateKeyPassword: host!.privateKeyPassword
            )
            
            // We haven't established our connection yet. That must be done before we create a terminal view
            if (session == nil) {
                session = SSHConnection(host: host_info!.hostname, andUsername: host_info!.username)
                do {
                    try session?.connect(hostInfo: host_info!)
                } catch SSHSessionError.authorizationFailed {
                    // TODO TJ how should we show these errors to users?
                    let error = SSHSessionError.authorizationFailed
                    print("[SSHSessionError] \(error)")
                } catch {
                    print("[SSHSessionError] \(error)")
                }
            }
        }
        
        if (host != nil && canvas == nil) {
            // Case: a terminal-only session.
            return AnyView(
                ZStack {
                    Color.black
                    SwiftUITerminal(canvas: $canvas, connection: $session, modifyTerminalHeight: false)
                }
                .navigationBarTitle("\(host!.name)")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(
                    trailing:
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
        } else if (host == nil && canvas != nil) {
            // Case: a canvas-only session.
            return AnyView(
                GeometryReader { geometry in
                    // if we are saving the drawing / exiting, change the background to white
                    // so that the canvas (zoomed out to avoid overhang) doesn't look weird.
                    savingDrawing ? Color.white : Color.black
                    CanvasViewWithNavigation(canvas: canvas!, canvasHeight: geometry.size.height, canvasWidth: geometry.size.width, showHostSheet: $showHostSheet, isDraw: $isDraw, isErase: $isErase, color: $color, type: $type, savingDrawing: $savingDrawing)
                    .sheet(
                        isPresented: $showHostSheet
                    ) {
                        SessionPageInputHost(host: $host, showHostSheet: $showHostSheet)
                    }
                }
            )
        } else {
            // Case: a canvas-and-terminal session.
            return AnyView(
                GeometryReader { geometry in
                    // if we are saving the drawing / exiting, change the background to white
                    // so that the canvas (zoomed out to avoid overhang) doesn't look weird.
                    savingDrawing ? Color.white : Color.black
                    VStack {
                        CanvasViewWithNavigation(canvas: canvas!, canvasHeight: geometry.size.height / 2, canvasWidth: geometry.size.width, showHostSheet: $showHostSheet, isDraw: $isDraw, isErase: $isErase, color: $color, type: $type, savingDrawing: $savingDrawing)
                        // TODO REFACTOR get connection. again should we open a new one here every time?
                        SwiftUITerminal(canvas: $canvas, connection: $session, modifyTerminalHeight: true)
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
                host: newHost,
                canvas: newCanvas
            ).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
}
