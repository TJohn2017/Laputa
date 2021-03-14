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
    case terminalOnly         // A terminal(s)-only session.
    case canvasOnly           // A canvas-only session.
    case splitSession         // A terminal(s) and canvas session.
    case error
}

struct SessionPageView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Environment(\.undoManager) private var undoManager

    @State var currCanvas: Canvas?
    @State var canvases: [Canvas?] = []
    @State var hosts: [Host?] = []
    @State var connections: [SSHConnection] = []
    
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
    
    init(startHost: Host? = nil, startCanvas: Canvas? = nil) {
        _currCanvas = State(initialValue: startCanvas)
        
        _hosts = State(initialValue: (startHost != nil && hosts.count == 0) ? [startHost] : [])
        _connections = State(initialValue: (startHost != nil && connections.count == 0) ? [SSHConnection(host: startHost!.host, andUsername: startHost!.username)] : [])
        _canvases = State(initialValue: (startCanvas != nil && canvases.count == 0) ? [startCanvas] : [])
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
                    // Choosing canvas to add.
                    case .addCanvas:
                        AddCanvasView(
                            canvas: $currCanvas,
                            selectedCanvases: $canvases,
                            activeSheet: $activeSheet
                        )
                    case .addHost:
                        AddHostView(
                            hosts: $hosts,
                            connections: $connections,
                            activeSheet: $activeSheet
                        )
                    default:
                        EmptyView()
                    }
                }
        }
    }
    
    var sessionInstance: some View {
        let sessionState = self.getSessionState()
        
        switch sessionState {
        case .terminalOnly:
            return AnyView(
               CustomTabView(
                    tabBarPosition: TabBarPosition.top,
                    numberOfElems: hosts.count
               ) {
                ForEach((0..<hosts.count), id: \.self) {
                        SwiftUITerminal(
                            canvas: $currCanvas,
                            connections: $connections,
                            connectionIdx: $0,
                            modifyTerminalHeight: false,
                            id: $0
                        )
                        .customTab(
                            name: "\(hosts[$0]!.name)",
                            tabNumber: $0
                        )
                    }
                }
               .onAppear(perform: establishConnection)
               .onChange(
                    of: self.connections,
                    perform: { _ in
                        self.establishConnection()
                    }
               )
            )
        case .canvasOnly:
            return AnyView(
                GeometryReader { geometry in
                    VStack {
                        CanvasView(
                            canvasId: currCanvas!.id,
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
        case .splitSession:
            return AnyView(
                GeometryReader { geometry in
                    VStack {
                        CanvasView(
                            canvasId: currCanvas!.id,
                            height: geometry.size.height / 2,
                            width: geometry.size.width,
                            pkCanvas: $pkCanvas,
                            isDraw: $isDraw,
                            isErase: $isErase,
                            color: $color,
                            type: $type,
                            savingDrawing: $backButtonPressed
                        )
                        .frame(width: geometry.size.width, height: geometry.size.height / 2)
                        CustomTabView(
                            tabBarPosition: TabBarPosition.top,
                             numberOfElems: hosts.count
                        ) {
                         ForEach((0..<hosts.count), id: \.self) {
                                 SwiftUITerminal(
                                     canvas: $currCanvas,
                                     connections: $connections,
                                     connectionIdx: $0,
                                     modifyTerminalHeight: true,
                                     id: $0
                                 )
                                 .frame(
                                     width: geometry.size.width,
                                     height: geometry.size.height / 2
                                 )
                                 .customTab(
                                     name: "\(hosts[$0]!.name)",
                                     tabNumber: $0
                                 )
                             }
                         }
                        .onAppear(perform: establishConnection)
                        .onChange(
                             of: self.connections,
                             perform: { _ in
                                 self.establishConnection()
                             }
                        )
                    }
                }
            )
        default:
            return AnyView(
                Text("Something went wrong!").foregroundColor(.purple)
            )
        }
    }

    func getSessionState() -> SessionState {
        if (hosts.count >= 1 && currCanvas == nil) {
            return SessionState.terminalOnly
        }
        else if (hosts.count == 0 && currCanvas != nil) {
            return SessionState.canvasOnly
        }
        else if (hosts.count >= 1 && currCanvas != nil) {
            return SessionState.splitSession
        }
        else {
            return SessionState.error
        }
    }
    
    func getNavigationBarTitle() -> String {
        let sessionState = self.getSessionState()
        switch sessionState {
        case SessionState.terminalOnly:
            return ""
        case SessionState.canvasOnly:
            return "\(currCanvas!.wrappedTitle)"
        case SessionState.splitSession:
            return "\(currCanvas!.wrappedTitle)"
        default:
            return ""
        }
    }
    
    var navigationBarLeadingButtons: some View {
        HStack(spacing: 15) {
            Button(action: {
                self.backButtonPressed.toggle()
                
                // Disconnect from each connection, if connected.
                for conn in self.connections {
                    conn.disconnect()
                }
                
                // Remove all cached terminal session states.
                SwiftUITerminal.dismantleAllSessionStates()
                
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
            || sessionState == SessionState.splitSession
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
                        self.activeSheet = ActiveSheet.addCanvas
                    }
                }) {
                    Label {
                        Text("Add Canvas")
                        
                    } icon : { Image(systemName: "rectangle")}
                }
                
                // Add terminal to session.
                Button(action: {
                    switch sessionState {
                    case SessionState.terminalOnly:
                        self.activeSheet = ActiveSheet.addHost
                    case SessionState.canvasOnly:
                        self.activeSheet = ActiveSheet.addHost
                    case SessionState.splitSession:
                        self.activeSheet = ActiveSheet.addHost
                    default:
                        break
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
    func establishConnection() {
        for (index, conn) in self.connections.enumerated() {
            if conn.isConnected() {
                continue
            }
            
            let host = self.hosts[index]
            
            if host == nil {
                continue
            }
            
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

            do {
                try conn.connect(hostInfo: host_info)
            } catch SSHSessionError.authorizationFailed {
                let error = SSHSessionError.authorizationFailed
                print("SessionPageView - establishConnection: \(error)")
            } catch {
                print("SessionPageView - establishConnection: \(error)")
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
                startHost: newHost,
                startCanvas: newCanvas
            ).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
}
