//
//  MainPageList.swift
//  Laputa
//
//  Created by Daniel Guillen on 2/9/21.
//

import SwiftUI

struct MainPageList: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        entity: Canvas.entity(),
        sortDescriptors: [NSSortDescriptor(key: "dateCreated", ascending: false)]
    )
    var canvases: FetchedResults<Canvas>
    
    @FetchRequest(
        entity: Host.entity(),
        sortDescriptors: []
    )
    var hosts: FetchedResults<Host>
    
    @Binding var displayHosts: Bool
    
    @State private var showDeleteAlert = false

    
    var body: some View {

        return AnyView(ScrollView {
            VStack {
                if (displayHosts) {
                    ForEach(hosts) { host in
                        HStack {
                            NavigationLink(
                                destination: SessionPageView(host: host)
                            ) {
                                MainPagePreview(host: host)
                            }
                            Menu() {
                                Button("Delete host", action: {
                                    viewContext.delete(host)
                                
                                    do {
                                        try viewContext.save()
                                        showDeleteAlert = true
                                        print("Host deleted.")
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
                                title: Text("Host deleted"),
                                message: Text("Host will now be removed."),
                                dismissButton: .default(Text("OK"))
                            )
                        }
                    }
                } else {
                    ForEach(canvases) { canvas in
                        HStack {
                            NavigationLink(
                                destination: SessionPageView(canvas: canvas)
                            ) {
                                MainPagePreview(canvas: canvas)
                            }
                            Menu() {
                                Button("Delete canvas", action: {
                                    viewContext.delete(canvas)
                                    
                                    do {
                                        try viewContext.save()
                                        showDeleteAlert = true
                                        print("Canvas deleted.")
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
                                title: Text("Canvas deleted"),
                                message: Text("Canvas will now be removed."),
                                dismissButton: .default(Text("OK"))
                            )
                        }
                    }
                }
            }
        })
    }
    
}

struct MainPageList_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper()
    }
    
    struct PreviewWrapper: View {
        @State private var displayHosts: Bool = false
        
        var body: some View {
            MainPageList(displayHosts: $displayHosts).environment(
                \.managedObjectContext,
                PersistenceController.preview.container.viewContext
            )
        }
    }
}
