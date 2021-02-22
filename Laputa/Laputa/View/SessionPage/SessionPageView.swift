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
    @State var canvas: Item?   // TODO: change to Canvas entity.
    @State var showCanvasSheet: Bool = false
    @State var showAddCanvasButton: Bool = true
    @State var hideAddCanvasButton : Bool = false
    
    // TODO: incorporate Canvas + Terminal Views.
    var body: some View {
        print ("RELOAD SESSION VIEW PAGE BODY")
        
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
                    SwiftUITerminal(host: host_info, showCanvasSheet: $showCanvasSheet, showAddCanvasButton: $showAddCanvasButton)
                }
                .navigationBarTitle("\(host!.name!)")
                .navigationBarTitleDisplayMode(.inline)
                .edgesIgnoringSafeArea(.top)
                .sheet(
                    isPresented: $showCanvasSheet
                ) {
                    SessionPageInputCanvas(canvas: canvas, showCanvasSheet: $showCanvasSheet)
                }
            )
        } else if (host == nil && canvas != nil) {
            return AnyView(Text("Canvas Session"))
        } else {
            //showAddCanvasButton = true
            let host_info = HostInfo(
                alias:host!.name!,
                hostname:host!.host!,
                username:host!.username!,
                usePassword:true,
                password:host!.password!
            )
            
            return AnyView(VStack {
                Text("CANVAS VIEW")
                SwiftUITerminal(host: host_info, showCanvasSheet: $showCanvasSheet, showAddCanvasButton: $hideAddCanvasButton)
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
            
            return SessionPageView(
                hostPresent: true,
                canvasPresent: false,
                host: newHost
            ).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
}
