//
//  AddHostView.swift
//  Laputa
//
//  Created by Daniel Guillen on 3/13/21.
//

import SwiftUI

struct AddHostView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        entity: Host.entity(),
        sortDescriptors: [NSSortDescriptor(key: "username", ascending: false)]
    )
    var fetchedHosts: FetchedResults<Host>
    
    // The array of hosts that the user eventually appends to from this view.
    @Binding var hosts: [Host?]
    // The array of connections where a new connection is added if a host is selected.
    @Binding var connections: [SSHConnection]
    // Keeps track of the active state of this sheet.
    @Binding var activeSheet: ActiveSheet?
    // Keeps track of the active state of a new input sheet when user wants to create a
    // new host
    @State var activeInputSheet: ActiveSheet?
    // Variable to pass to the input sheet if the user wants to create a new host.
    @State var selectedHost: Host?
    
    var body: some View {
        ZStack {
            Color("HostMain")
            VStack {
                Text("Choose a host to add")
                    .foregroundColor(.white)
                    .font(.largeTitle)
                    .padding(.top, 50)
                
                // Add a new host.
                ZStack {
                    RoundedRectangle(cornerRadius: 30)
                        .frame(width: 205, height: 50)
                        .foregroundColor(Color.white)
                    
                    Button(action: {
                        activeInputSheet = .inputSheet
                        selectedHost = nil
                    }) {
                        HStack {
                            Image(systemName: "plus.circle")
                            Text("New Host").bold()
                        }
                        .font(.title)
                        .foregroundColor(Color("HostMain"))
                    }
                }
                .padding(.bottom, 30)
                
                // Choose from an existing host.
                ScrollView {
                    VStack {
                        ForEach(fetchedHosts) { host in
                            Button(action: {
                                hosts.append(host)
                                connections.append(SSHConnection(host: host.host, andUsername: host.username))
                                activeSheet = nil
                            }) {
                                HStack {
                                    Spacer()
                                    ZStack(alignment: Alignment(horizontal: .leading, vertical: .center)) {
                                        RoundedRectangle(cornerRadius: 10)
                                            .frame(width: 550.0, height: 100.0)
                                            .padding()
                                            .foregroundColor(Color.white)
                                            .shadow(color: Color(white: 0, opacity: 0.3), radius: 4, x: -3, y: 3)
                                        HStack {
                                            Image(systemName: "chevron.right.square.fill")
                                                .font(.largeTitle)
                                                .foregroundColor(Color("HostMain"))
                                            VStack(alignment: .leading) {
                                                Text("\(host.name)")
                                                    .font(.title)
                                                    .foregroundColor(Color.black)
                                                Text("\(host.host) | \(host.username)")
                                                    .foregroundColor(Color.gray)
                                                    .padding(2)
                                            }
                                            .padding()
                                        }
                                        .padding(.leading, 50)
                                    }
                                    Spacer()
                                }
                            }
                        }
                    }
                    .sheet(
                        item: $activeInputSheet,
                        onDismiss: {
                            if selectedHost != nil {
                                hosts.append(selectedHost!)
                                connections.append(SSHConnection(host: selectedHost!.host, andUsername: selectedHost!.username))
                            }
                        }
                    ) { item in
                        InputHostView(
                            activeSheet: $activeInputSheet,
                            parentActiveSheet: $activeSheet,
                            selectedHost: $selectedHost
                        )
                    }
                }
            }
        }
    }
}

struct AddHostView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper()
    }
    
    struct PreviewWrapper: View {
        @State var hosts: [Host?] = [Host?]()
        @State var connections: [SSHConnection] = [SSHConnection]()
        @State var activeSheet: ActiveSheet?
        
        var body: some View {
            
            return AddHostView(
                hosts: $hosts,
                connections: $connections,
                activeSheet: $activeSheet
            ).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
}
