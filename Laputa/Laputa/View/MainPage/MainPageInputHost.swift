//
//  MainPageInputHost.swift
//  Laputa
//
//  Created by Daniel Guillen on 2/16/21.
//

import SwiftUI

struct MainPageInputHost: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @Binding var showingInputSheet: Bool


    @State var name: String = ""
    @State var host: String = ""
    @State var port: String = "22"
    @State var username: String = ""
    @State var password: String = ""
    @State var publicKey: String = ""
    @State var privateKey: String = ""
    @State var selectedAuthenticationType = AuthenticationType.password
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Host Info")) {
                    HStack {
                        Text("Name")
                        TextField("Optional", text: $name).multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("Username")
                        TextField("Required", text: $username).multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("Host")
                        TextField("Required", text: $host).multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("Port")
                        TextField("Required", text: $port).multilineTextAlignment(.trailing)
                    }
                }
                
                Section(header: Text("Authentication")) {
                    Picker("Authentication Type", selection:$selectedAuthenticationType) {
                        Text("Password").tag(AuthenticationType.password)
                        Text("Public / Private Key").tag(AuthenticationType.publicPrivateKey)
                    }
                    
                    if (self.selectedAuthenticationType == AuthenticationType.password) {
                        HStack {
                            Text("Password")
                            TextField("Required", text: $password).multilineTextAlignment(.trailing)
                        }
                    } else {
                        HStack {
                            Text("Public Key")
                            TextField("Required", text: $publicKey).multilineTextAlignment(.trailing)
                        }
                        HStack {
                            Text("Private Key")
                            TextField("Required", text: $privateKey).multilineTextAlignment(.trailing)
                        }
                    }
                }
                
                Button(action: {
                    // Ensure that required fields are met.
                    guard self.username != "" else {return}
                    guard self.host != "" else {return}
                    guard self.port != "" else {return}
                    if (self.selectedAuthenticationType == AuthenticationType.password) {
                        guard self.password != "" else {return}
                    } else {
                        guard self.publicKey != "" else {return}
                        guard self.privateKey != "" else {return}
                    }
                    
                    let newHost = Host(context: viewContext)
                    newHost.name = self.name
                    newHost.username = self.username
                    newHost.host = self.host
                    newHost.port = self.port
                    newHost.authenticationType = self.selectedAuthenticationType
                    newHost.password = self.password
                    newHost.publicKey = self.publicKey
                    newHost.privateKey = self.privateKey
                    
                    // Save the created host.
                    do {
                        try viewContext.save()
                        print("Host w/ name: \(self.name) saved.")
                        showingInputSheet.toggle()
                    } catch {
                        print(error.localizedDescription)
                    }
                    
                }) {
                    Text("Add Host")
                }
                
            }
            .navigationBarTitle("")
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private func addHostEntity() {
        
    }
}

struct MainPageInputHost_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper()
    }
    
    struct PreviewWrapper: View {
        @State var showingInputSheet = true

        var body: some View {
            
            return MainPageInputHost(
                showingInputSheet: $showingInputSheet
            ).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
}
