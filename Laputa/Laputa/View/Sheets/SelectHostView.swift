//
//  SelectHostView.swift
//  Laputa
//
//  Created by Claire Mai on 3/3/21.
//
//  A list of hosts for when the user wants to select a host to use
//  in tandem with an already selected canvas.
//

import SwiftUI

struct SelectHostView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        entity: Host.entity(),
        sortDescriptors: [NSSortDescriptor(key: "username", ascending: false)]
    )
    var hosts: FetchedResults<Host>
    
    // the host that the user eventually selects from this view
    @Binding var selectedHost: Host?
    // the selected canvas that the user wants to use with a host
    @Binding var selectedCanvas: Canvas?
    // If we're coming from the main page, whether or not navigation
    // to session page behind sheet should be activated
    @Binding var navToSessionActive: Bool
    // keeps track of the active state of this sheet
    @Binding var activeSheet: ActiveSheet?
    // keeps track of the active state of a new input sheet when user wants to create a new host
    @State var activeInputSheet: ActiveSheet?
        
    var body: some View {
        return ZStack {
            Color("HostMain")
            VStack {
                (Text("Choose a host to use with ") + Text("\(selectedCanvas!.wrappedTitle)").bold())
                    .foregroundColor(.white)
                    .font(.largeTitle)
                    .padding(.top, 50)
                
                // Add a new host
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
                            Text("New Host")
                                .bold()
                        }
                        .font(.title)
                        .foregroundColor(Color("HostMain"))
                    }
                    
                }
                .padding(.bottom, 30)
                
                // Choose from an existing host
                ScrollView {
                    VStack {
                        ForEach(hosts) { host in
                            Button(action: {
                                selectedHost = host
                                navToSessionActive.toggle()
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
                                navToSessionActive.toggle()
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

struct SelectHostView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper()
    }
    
    struct PreviewWrapper: View {
        @State var host: Host?
        @State var showHostSheet: Bool = true
        @State var navToSessionActive: Bool = false
        @State var activeSheet: ActiveSheet?
        
        var body: some View {
            let context = PersistenceController.preview.container.viewContext
            let canvas = Canvas(context: context)
            canvas.id = UUID()
            canvas.dateCreated = Date()
            canvas.title = "Test Canvas"
            
            return SelectHostView(
                selectedHost: $host,
                selectedCanvas: .constant(canvas),
                navToSessionActive: $navToSessionActive,
                activeSheet: $activeSheet
            ).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
}
