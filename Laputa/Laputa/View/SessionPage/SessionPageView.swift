//
//  SessionPageView.swift
//  Laputa
//
//  Created by Daniel Guillen on 2/20/21.
//

import SwiftUI
import UIKit

struct SessionPageView: View {
    @State var hostPresent: Bool
    @State var canvasPresent: Bool
    @State var host: Host?
    @State var canvas: Canvas?
    @State var showCanvasSheet: Bool = false
    
    // TODO: incorporate Canvas + Terminal Views.
    var body: some View {
        if (host != nil && canvas == nil) {
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
                    SwiftUITerminal(host: host_info, showCanvasSheet: $showCanvasSheet, modifyTerminalHeight: false)
                }
                .navigationBarTitle("\(host!.name!)")
                .navigationBarTitleDisplayMode(.inline)
                .edgesIgnoringSafeArea(.top)
                .sheet(
                    isPresented: $showCanvasSheet
                ) {
                    SessionPageInputCanvas(canvas: $canvas, showCanvasSheet: $showCanvasSheet)
                }
            )
        } else if (host == nil && canvas != nil) {
            return AnyView(
                GeometryReader { geometry in
                    ZStack {
                    Color.black
                    CanvasView(canvasId: canvas!.id, isSplitView: false, height: geometry.size.height, width: geometry.size.width)
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .navigationBarTitle("\(canvas!.wrappedTitle)")
                    .navigationBarTitleDisplayMode(.inline)
                }
            )
        } else {
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
                        CanvasView(canvasId: canvas!.id, isSplitView: true, height: geometry.size.height / 2)
                            .frame(width: geometry.size.width, height: geometry.size.height / 2)
                        SwiftUITerminal(host: host_info, showCanvasSheet: $showCanvasSheet, modifyTerminalHeight: true)
                            .frame(width: geometry.size.width, height: geometry.size.height / 2)
                    }
                })
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
                hostPresent: false,
                canvasPresent: true,
//                host: newHost,
                canvas: newCanvas
            ).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
}
