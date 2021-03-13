//
//  SessionPageView.swift
//  Laputa
//
//  Created by Daniel Guillen on 2/20/21.
//

import SwiftUI
import UIKit
import PencilKit

enum SessionState: String {
    case terminalOnlyConnected      // A terminal-only session w/ active connection.
    case terminalOnlyNotConnected   // A terminal-only session w/ non-active connection.
    case canvasOnly                 // A canvas-only session.
    case splitConnected             // A connected terminal and canvas session.
    case splitNotConnected          // A non-connected terminal and canvas session.
    case error
}

struct SessionPageView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Environment(\.undoManager) private var undoManager
    
    @State var host: Host?
    @State var canvas: Canvas?
    @State var session: SSHConnection?
    @State var activeSheet: ActiveSheet?
    
    // State vars for PKDrawingView
    @State var isDraw = true
    @State var isErase = false
    @State var color : Color = Color.black
    @State var type : PKInkingTool.InkType = .pencil
    @State var pkCanvas = PKCanvasView()
    
    // backButtonPressed is passed into CanvasView/PKDrawingView so that
    // when it is toggled by the back button, the view will update and
    // save the current drawing.
    @State var backButtonPressed : Bool = false
    
    // gesture to drag split pane up or down
    @GestureState var dragState = CGSize.zero
    @State var splitFrac: CGFloat = 0.5
    @State var height: CGFloat = UIScreen.main.bounds.height
    
    func getResizeGesture(geoHeight: CGFloat) -> some Gesture {
        return DragGesture()
            .updating($dragState) { value, state, transaction in
                state = value.translation
            }
            .onEnded() { value in
                splitFrac += value.translation.height / geoHeight
            }
    }
    
    func getResizeDragger(geoHeight: CGFloat) -> some View {
        return ZStack {
            RoundedRectangle(cornerRadius: 8)
                .frame(width: 100, height: 20)
                .foregroundColor(Color.gray)
            HStack {
                Rectangle()
                    .frame(width: 2, height: 12)
                Spacer()
                    .frame(width: 2)
                Rectangle()
                    .frame(width: 2, height: 12)
                Spacer()
                    .frame(width: 2)
                Rectangle()
                    .frame(width: 2, height: 12)
            }
            .foregroundColor(Color(white: 0, opacity: 0.3))
        }
        .offset(
            x: .zero,
            y: (splitFrac + (dragState.height / geoHeight) - 0.5) * geoHeight
        )
        .gesture(getResizeGesture(geoHeight: geoHeight))
    }
    
    var body: some View {
        ZStack {
            Color("CanvasMain")
            self.sessionInstance
                .navigationBarTitle("")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarBackButtonHidden(true)
                .navigationBarHidden(self.backButtonPressed)
                .navigationBarItems(
                    leading: self.navigationBarLeadingButtons,
                    trailing: self.navigationBarTrailingButtons
                )
                .sheet(item: $activeSheet) { item in
                    switch item {
                    // Choosing canvas to use with a host.
                    case .selectCanvas:
                        SelectCanvasView(
                            selectedHost: $host,
                            selectedCanvas: $canvas,
                            navToSessionActive: .constant(false),
                            activeSheet: $activeSheet
                        )
                    // Choosing host to use with a canvas.
                    case .selectHost:
                        SelectHostView(
                            selectedHost: $host,
                            selectedCanvas: $canvas,
                            navToSessionActive: .constant(false),
                            activeSheet: $activeSheet
                        )
                    default:
                        EmptyView()
                    }
                }
        }
    }
    
//    var ResizeDragger: some View {
//        return RoundedRectangle(cornerRadius: 10)
//            .frame(width: 100, height: 20)
//            .foregroundColor(.red)
//            .offset(x: .zero, y: -(0.5 - splitFrac - (dragState.height / UIScreen.main.bounds.height)) * UIScreen.main.bounds.height)
//            .gesture(resizeSplit)
//    }
    
    var sessionInstance: some View {
        let sessionState = self.getSessionState()
        
        switch sessionState {
        case .terminalOnlyConnected:
            return AnyView(
                SwiftUITerminal(
                    canvas: $canvas,
                    connection: $session,
                    modifyTerminalHeight: false
                )
            )
        case .terminalOnlyNotConnected:
            return AnyView(
                Text("Not connected.")
                    .onAppear(perform: establishConnection)
            )
        case .canvasOnly:
            return AnyView(
                GeometryReader { geometry in
                    VStack {
                        CanvasView(
                            canvasId: canvas!.id,
                            height: geometry.size.height,
                            width: geometry.size.width,
                            pkCanvas: $pkCanvas,
                            isDraw: $isDraw,
                            isErase: $isErase,
                            color: $color,
                            type: $type,
                            savingDrawing: $backButtonPressed
                        )
                        .frame(
                            width: geometry.size.width,
                            height: geometry.size.height
                        )
                    }
                }
            )
        case .splitConnected:
            return AnyView(
                GeometryReader { geometry in
                    ZStack {
                        VStack {
                            CanvasView(
                                canvasId: canvas!.id,
                                height: geometry.size.height * (splitFrac + (dragState.height / geometry.size.height)),
                                width: geometry.size.width,
                                pkCanvas: $pkCanvas,
                                isDraw: $isDraw,
                                isErase: $isErase,
                                color: $color,
                                type: $type,
                                savingDrawing: $backButtonPressed
                            )
                            .frame(
                                width: geometry.size.width,
                                height: geometry.size.height * (splitFrac + (dragState.height / geometry.size.height))
                            )
                            SwiftUITerminal(
                                canvas: $canvas,
                                connection: $session,
                                modifyTerminalHeight: true
                            )
                            .frame(
                                width: geometry.size.width,
                                height: geometry.size.height * (1 - (splitFrac + (dragState.height / geometry.size.height)))
                            )
                        }
                        getResizeDragger(geoHeight: geometry.size.height)
                    }
                }
            )
        case .splitNotConnected:
            return AnyView(
                GeometryReader { geometry in
                    ZStack {
                        VStack {
                            CanvasView(
                                canvasId: canvas!.id,
                                height: geometry.size.height * (splitFrac + (dragState.height / geometry.size.height)),
                                width: geometry.size.width,
                                pkCanvas: $pkCanvas,
                                isDraw: $isDraw,
                                isErase: $isErase,
                                color: $color,
                                type: $type,
                                savingDrawing: $backButtonPressed
                            )
                            .frame(
                                width: geometry.size.width,
                                height: geometry.size.height * (splitFrac + (dragState.height / geometry.size.height))
                            )
                            Text("Not connected.")
                                .frame(
                                    width: geometry.size.width,
                                    height: geometry.size.height * (1 - (splitFrac + (dragState.height / geometry.size.height)))
                                )
                        }
                        getResizeDragger(geoHeight: geometry.size.height)
                    }
                    .onAppear(perform: establishConnection)
                }
            )
        default:
            return AnyView(
                Text("Something went wrong!").foregroundColor(.purple)
            )
        }
    }
    
    func getSessionState() -> SessionState {
        if (self.host != nil && self.session != nil && self.canvas == nil) {
            return SessionState.terminalOnlyConnected
        } else if (host != nil && session == nil && canvas == nil) {
            return SessionState.terminalOnlyNotConnected
        } else if (host == nil && canvas != nil) {
            return SessionState.canvasOnly
        } else if (host != nil && session != nil && canvas != nil) {
            return SessionState.splitConnected
        } else if (host != nil && session == nil && canvas != nil) {
            return SessionState.splitNotConnected
        } else {
            return SessionState.error
        }
    }
    
    func getNavigationBarTitle() -> String {
        let sessionState = self.getSessionState()
        switch sessionState {
        case SessionState.terminalOnlyConnected:
            return "\(host!.name)"
        case SessionState.terminalOnlyNotConnected:
            return "\(host!.name)"
        case SessionState.canvasOnly:
            return "\(canvas!.wrappedTitle)"
        case SessionState.splitConnected:
            return "\(canvas!.wrappedTitle)  |  \(host!.name)"
        case SessionState.splitNotConnected:
            return "\(canvas!.wrappedTitle)  |  \(host!.name)"
        default:
            return ""
        }
    }
    
    var navigationBarLeadingButtons: some View {
        HStack(spacing: 15) {
            Button(action: {
                self.backButtonPressed.toggle()
                
                // Disconnect from session, if connected.
                if (self.session != nil) {
                    self.session?.disconnect()
                }
                
                self.presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "chevron.left").font(.title2)
            }
            
            Text("\(self.getNavigationBarTitle())")
        }
    }
    
    var navigationBarTrailingButtons: some View {
        let sessionState = self.getSessionState()
        let canvasIsActive: Bool = (
            sessionState == SessionState.canvasOnly
                || sessionState == SessionState.splitConnected
                || sessionState == SessionState.splitNotConnected
        )
        
        return HStack(spacing: 15) {
            if (canvasIsActive) {
                // Undo button.
                Button(action: {
                    undoManager?.undo()
                }) {
                    Image(systemName: "arrow.counterclockwise")
                }
                
                // Redo button.
                Button(action: {
                    undoManager?.redo()
                }) {
                    Image(systemName: "arrow.clockwise")
                }
                
                // Pencil button.
                Button(action: {
                    self.isDraw = true
                    self.isErase = false
                    self.type = .pencil
                }) {
                    Image(systemName: "pencil")
                        .foregroundColor(self.isDraw && self.type == .pencil ? .blue : .black)
                }
                
                // Pen button.
                Button(action: {
                    self.isDraw = true
                    self.isErase = false
                    self.type = .pen
                }) {
                    Image(systemName: "pencil.tip")
                        .foregroundColor(self.isDraw && self.type == .pen ? .blue : .black)
                }
                
                // Marker button.
                Button(action: {
                    self.isDraw = true
                    self.isErase = false
                    self.type = .marker
                }) {
                    Image(systemName: "highlighter")
                        .foregroundColor(self.isDraw && self.type == .marker ? .blue : .black)
                }
                
                // Eraser button.
                Button(action: {
                    self.isDraw = false
                    self.isErase = true
                }) {
                    Image("erase_icon")
                        .resizable()
                        .frame(width: 35, height: 35)
                        .foregroundColor(self.isErase ? .blue : .black)
                }
                
                // Lasso cut tool.
                Button(action: {
                    self.isDraw = false
                    self.isErase = false
                }) {
                    Image(systemName: "scissors")
                        .font(.title2)
                        .foregroundColor(!self.isErase && !self.isDraw ? .blue : .black)
                }
                
                ColorPicker("", selection: $color)
            }
            
            Menu {
                // Add canvas to session.
                Button(action: {
                    // TODO: add more than one canvas.
                    if (!canvasIsActive) {
                        self.activeSheet = ActiveSheet.selectCanvas
                    }
                }) {
                    Label {
                        Text("Add Canvas")
                        
                    } icon : { Image(systemName: "rectangle")}
                }
                
                // Add terminal to session.
                Button(action: {
                    // TODO: add more than one terminal.
                    if (sessionState == SessionState.canvasOnly) {
                        self.activeSheet = ActiveSheet.selectHost
                    }
                }) {
                    Label {
                        Text("Add Terminal")
                        
                    } icon: { Image(systemName: "greaterthan.square.fill")}
                }
            } label : {
                Image(systemName: "plus").font(.title)
            }
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
