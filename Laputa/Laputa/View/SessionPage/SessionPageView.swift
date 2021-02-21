//
//  SessionPageView.swift
//  Laputa
//
//  Created by Daniel Guillen on 2/20/21.
//

import SwiftUI

struct SessionPageView: View {
    @State var hostPresent: Bool
    @State var canvasPresent: Bool
    @State var host: Host?
    @State var canvas: Item?   // TODO: change to Canvas entity.
    
    // TODO: incorporate Canvas + Terminal Views.
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
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
            newHost.host = "host_1"
            newHost.name = "Name #1"
            newHost.password = "password_1"
            newHost.port = "22"
            newHost.username = "username_1"
            
            return SessionPageView(
                hostPresent: true,
                canvasPresent: false,
                host: newHost
            ).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
}
