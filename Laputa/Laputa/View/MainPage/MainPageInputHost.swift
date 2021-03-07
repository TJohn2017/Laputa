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
    // if this is not nil, we are editing an existing host
    @Binding var selectedHost: Host?

    @State var name: String = ""
    @State var host: String = ""
    @State var port: String = "22"
    @State var username: String = ""
    @State var password: String = ""
    @State var publicKey: String = ""
    @State var privateKey: String = ""
    @State var privateKeyPassword: String = ""
    @State var selectedAuthenticationType = AuthenticationType.password
    
    // fill form with existing host information if there is one
    func populate() {
        if selectedHost != nil {
            name = selectedHost!.name!
            host = selectedHost!.host!
            port = selectedHost!.port!
            username = selectedHost!.username!
            password = selectedHost!.password!
        }
    }
    
    func saveHost() {      
        // Ensure that required fields are met.
        guard self.name != "" else {return}
        guard self.username != "" else {return}
        guard self.host != "" else {return}
        guard self.port != "" else {return}
        if (self.selectedAuthenticationType == AuthenticationType.password) {
            guard self.password != "" else {return}
        } else {
            guard self.publicKey != "" else {return}
            guard self.privateKey != "" else {return}
            guard self.privateKeyPassword != "" else {return}
        }

        // Creating a new host
        if selectedHost == nil {
            selectedHost = Host(context: viewContext)
        }
        selectedHost!.name = self.name
        selectedHost!.username = self.username
        selectedHost!.host = self.host
        selectedHost!.port = self.port
        selectedHost!.authenticationType = self.selectedAuthenticationType
        selectedHost!.password = self.password
        selectedHost!.publicKey = self.publicKey
        selectedHost!.privateKey = self.privateKey
        selectedHost!.privateKeyPassword = self.privateKeyPassword

        // Save the created host.
        do {
            try viewContext.save()
            print("Host w/ name: \(self.name) saved.")
            showingInputSheet.toggle()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Host Info")) {
                    HStack {
                        Text("Name")
                        TextField("Required", text: $name).multilineTextAlignment(.trailing)
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
                        HStack {
                            Text("Password for encrypted private key")
                            TextField("Required", text: $privateKeyPassword).multilineTextAlignment(.trailing)
                        }
                    }
                }
                
                Button(action: saveHost) {
                    Text(selectedHost == nil ? "Add Host" : "Save Changes")
                }
                
            }
            .navigationBarTitle("")
            .navigationBarHidden(true)
            .onAppear(perform: populate)
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
                showingInputSheet: $showingInputSheet,
                selectedHost: .constant(nil)
            ).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
}
