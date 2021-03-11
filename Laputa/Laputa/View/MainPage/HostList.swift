//
//  HostList.swift
//  Laputa
//
//  Created by Cynthia Jia on 3/6/21.
//

import SwiftUI

struct HostList: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @Binding var activeSheet: ActiveSheet?
    
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
            Spacer().frame(height: 20)
            ForEach(hosts) { host in
                HStack {
                    Spacer()
                    NavigationLink(
                        destination: SessionPageView(host: host)
                    ) {
                        ZStack(alignment: Alignment(horizontal: .leading, vertical: .center)) {
                            RoundedRectangle(cornerRadius: 10)
                                .frame(width: 600.0, height: 100.0)
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
                    }
                    
                    Menu() {
                        Button("Open with a canvas", action: {
                            activeSheet = .selectCanvas
                            selectedHost = host
                        })
                        Button("Edit host", action: {
                            activeSheet = .inputSheet
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
                    
                    Spacer()
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
        @State private var activeSheet: ActiveSheet?
        
        var body: some View {
            HostList(
                activeSheet: $activeSheet,
                selectedHost: .constant(nil)
            ).environment(
                \.managedObjectContext,
                PersistenceController.preview.container.viewContext
            )
        }
    }
}
