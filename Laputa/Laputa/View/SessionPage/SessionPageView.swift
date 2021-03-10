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
        // TODO TJ right now we're only checking nil session, not connection status
        if (host != nil && session != nil && canvas == nil) {
            // Case: a terminal-only session with an active connection
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
        } else if (host != nil && session == nil && canvas == nil) {
            // TODO replace with a real not connected view
            // Case: a terminal-only session without an active connection
            return AnyView(
                Text("Not connected.")
                .onAppear(perform: establishConnection)
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
        } else if (host != nil && session != nil && canvas != nil){
            print("LOG: about to render both host and canvas with session = \(session != nil)")
            // Case: a canvas-and-terminal session with an active connection.
            return AnyView(
                GeometryReader { geometry in
                    // if we are saving the drawing / exiting, change the background to white
                    // so that the canvas (zoomed out to avoid overhang) doesn't look weird.
                    savingDrawing ? Color.white : Color.black
                    VStack {
                        CanvasViewWithNavigation(canvas: canvas!, canvasHeight: geometry.size.height / 2, canvasWidth: geometry.size.width, showHostSheet: $showHostSheet, isDraw: $isDraw, isErase: $isErase, color: $color, type: $type, savingDrawing: $savingDrawing)
                        SwiftUITerminal(canvas: $canvas, connection: $session, modifyTerminalHeight: true)
                            .frame(width: geometry.size.width, height: geometry.size.height / 2)
                    }
                }
            )
        } else {
            // TODO replace with a real not connected view
            // Case: a canvas-and-terminal session without an active connection.
            return AnyView(
                GeometryReader { geometry in
                    // if we are saving the drawing / exiting, change the background to white
                    // so that the canvas (zoomed out to avoid overhang) doesn't look weird.
                    savingDrawing ? Color.white : Color.black
                    VStack {
                        CanvasViewWithNavigation(canvas: canvas!, canvasHeight: geometry.size.height / 2, canvasWidth: geometry.size.width, showHostSheet: $showHostSheet, isDraw: $isDraw, isErase: $isErase, color: $color, type: $type, savingDrawing: $savingDrawing)
                        Text("Not connected.")
                            .frame(width: geometry.size.width, height: geometry.size.height / 2)
                    }
                    .onAppear(perform: establishConnection)
                }
            )
        }
    }
    
    // This function should be run on the appearance of any of the above views which have a terminal.
    // It is used to establish the ssh connection for the terminal from the given host data.
    private func establishConnection() {
        if (self.host != nil) {
            let host_info = HostInfo(
                alias: host!.name,
                username: host!.username,
                hostname: host!.host,
                authType: host!.authenticationType,
                password: host!.password,
                publicKey: host!.publicKey,
                privateKey: host!.privateKey,
                privateKeyPassword: host!.privateKeyPassword
            )
            
            // We haven't established our connection yet. That must be done for a working terminal view
            if (self.session == nil) {
                self.session = SSHConnection(host: host_info.hostname, andUsername: host_info.username)
                do {
                    try self.session?.connect(hostInfo: host_info)
                } catch SSHSessionError.authorizationFailed {
                    // TODO TJ how should we show these errors to users?
                    let error = SSHSessionError.authorizationFailed
                    print("[SSHSessionError] \(error)")
                } catch {
                    print("[SSHSessionError] \(error)")
                }
            }
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
