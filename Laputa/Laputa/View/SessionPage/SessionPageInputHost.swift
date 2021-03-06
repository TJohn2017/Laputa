//
//  SessionPageInputHost.swift
//  Laputa
//
//  Created by Claire Mai on 3/3/21.
//

import SwiftUI

struct SessionPageInputHost: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        entity: Host.entity(),
        sortDescriptors: [NSSortDescriptor(key: "username", ascending: false)]
    )
    var hosts: FetchedResults<Host>
    
    @Binding var host: Host?
    @Binding var showHostSheet: Bool
    @State private var showingInputSheet: Bool = false
    
    var body: some View {
        return VStack {
            Text("Add a host in split view")
                .font(.title)
                .padding(.top, 50)
            ScrollView {
                VStack {
                    // Add a new host which will appear at the
                    // top of the list since it was most recently made
                    Button(action: {
                        showingInputSheet.toggle()
                    }) {
                        HStack {
                            Image(systemName: "plus.circle")
                            Text("New Host")
                        }
                        .font(.title)
                    }
                    .padding(50)
                    
                    ForEach(hosts) { host in
                        Button(action: {
                            self.host = host
                            showHostSheet.toggle()
                        }) {
                            VStack {
                                Text("\(host.name!)")
                                    .frame(width: 400.0, height: 200.0)
                                    .padding()
                                    .background(Color.red)
                                    .foregroundColor(Color.black)
                                    .cornerRadius(10.0)
                                Text("Host: \(host.host!)")
                                    .foregroundColor(Color.black)
                            }.padding()
                        }
                    }
                }
                .sheet(
                    isPresented: $showingInputSheet,
                    onDismiss: {
                        // TODO Bring the user back to split view with the newly made host
                    }
                ) {
                    MainPageInputHost(showingInputSheet: $showingInputSheet)
                }
            }
        }
    }
}

struct SessionPageInputHost_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper()
    }
    
    struct PreviewWrapper: View {
        @State var host: Host?
        @State var showHostSheet: Bool = true
        
        var body: some View {
            
            return SessionPageInputHost(
                host: $host,
                showHostSheet: $showHostSheet
            ).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
}
