//
//  HostList.swift
//  Laputa
//
//  Created by Cynthia Jia on 3/6/21.
//

import SwiftUI

struct HostList: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @Binding var showingInputSheet: Bool
    // passed up to MainPageView where editing host info sheet is located
    @Binding var selectedHost: Host?
    
    @State private var showDeleteAlert: Bool = false
    // store name of deleted host so it can be displayed to user
    @State var deletedName = ""
    
    @FetchRequest(
        entity: Host.entity(),
        sortDescriptors: []
    )
    var hosts: FetchedResults<Host>
    
    var body: some View {
        VStack {
            ForEach(hosts) { host in
                HStack {
                    NavigationLink(
                        destination: SessionPageView(host: host)
                    ) {
                        VStack {
                            Text("\(host.name)")
                                .frame(width: 400.0, height: 200.0)
                                .padding()
                                .background(Color.red)
                                .foregroundColor(Color.black)
                                .cornerRadius(10.0)
                                .font(.largeTitle)
                            Text("\(host.host) | \(host.username)")
                                .foregroundColor(Color.white)
                        }.padding()
                    }
                    Menu() {
                        Button("Edit host", action: {
                            showingInputSheet.toggle()
                            selectedHost = host
                        })
                        Button("Delete host", action: {
                            deletedName = host.name
                            viewContext.delete(host)
                            
                            do {
                                try viewContext.save()
                                showDeleteAlert.toggle()
                                print("Host \"\(deletedName)\" deleted.")
                            } catch {
                                print(error.localizedDescription)
                            }
                        })
                    } label: {
                        Label("", systemImage: "ellipsis.circle")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                    }
                }.alert(isPresented: $showDeleteAlert) {
                    Alert(
                        title: Text("Host \"\(deletedName)\" deleted"),
                        dismissButton: .default(Text("OK"))
                    )
                }
            }
        }
    }
}

struct HostList_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper()
    }
    
    struct PreviewWrapper: View {
        @State private var showingInputSheet: Bool = false
        
        var body: some View {
            HostList(showingInputSheet: $showingInputSheet, selectedHost: .constant(nil)).environment(
                \.managedObjectContext,
                PersistenceController.preview.container.viewContext
            )
        }
    }
}
