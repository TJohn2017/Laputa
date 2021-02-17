//
//  MainPageInputHost.swift
//  Laputa
//
//  Created by Daniel Guillen on 2/16/21.
//

import SwiftUI

struct MainPageInputHost: View {
    @State var name: String = ""
    @State var host: String = ""
    @State var port: String = "22"
    @State var username: String = ""
    @State var password: String = ""
    
    var body: some View {
        Form {
            Section(header: Text("Host Info")) {
                HStack {
                    Text("Name")
                    TextField("Optional", text: $name).multilineTextAlignment(.trailing)
                }
                HStack {
                    Text("Host")
                    TextField("Required", text: $host).multilineTextAlignment(.trailing)
                }
                HStack {
                    Text("Port")
                    TextField("Required", text: $port).multilineTextAlignment(.trailing)
                }
                HStack {
                    Text("Username")
                    TextField("Required", text: $username).multilineTextAlignment(.trailing)
                }
                HStack {
                    Text("Password")
                    TextField("Required", text: $password).multilineTextAlignment(.trailing)
                }
            }
            
            Button(action: {
                // View needs to set the startSession binding variable to true once the input is validated.
            }) {
                Text("Add Host")
            }
            
        }
    }
}

struct MainPageInputHost_Previews: PreviewProvider {
    static var previews: some View {
        MainPageInputHost()
    }
}
