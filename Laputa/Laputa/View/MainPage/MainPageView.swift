//
//  MainPageView.swift
//  Laputa
//
//  Created by Daniel Guillen on 2/9/21.
//

import SwiftUI

// different sheets that can be active on the main page
enum ActiveSheet: Identifiable {
    // inputSheet: creating or editing host/canvas info
    // selectCanvas: choosing a canvas to use in tandem with a selected host
    // selectHost: choosing a host to use in tandem with a selected canvas
    case inputSheet, selectCanvas, selectHost
    
    var id: Int {
        hashValue
    }
}

struct MainPageView: View {
    @State private var displayHosts: Bool = true
    @State private var showingInputSheet: Bool = false
    
    @State var canvas: Canvas? = nil
    @State var host: Host? = nil
    
    @State var selectedCanvas: Canvas? = nil
    @State var selectedHost: Host? = nil
    
    @State var activeSheet: ActiveSheet?
    @State var navToSessionActive: Bool = false
    
    var body: some View {
        NavigationView {
            ZStack {
                displayHosts ?
                    Color("HostMain") :
                    Color("CanvasMain")
                VStack {
                    MainPageHeaderView(
                        displayHosts: $displayHosts,
                        activeSheet: $activeSheet,
                        selectedHost: $selectedHost,
                        selectedCanvas: $selectedCanvas
                    )
                    MainPageList(
                        displayHosts: $displayHosts,
                        activeSheet: $activeSheet,
                        selectedHost: $selectedHost,
                        selectedCanvas: $selectedCanvas
                    )
                }
            }
            .navigationBarTitle("")
            .navigationBarHidden(true)
            .edgesIgnoringSafeArea(.all) // Add to cover-up status bar.
            
            .sheet(item: $activeSheet) { item in
                switch item {
                // creating/editing host/canvas info
                case .inputSheet:
                    EntityInputView(
                        displayHosts: $displayHosts,
                        activeSheet: $activeSheet,
                        selectedHost: $selectedHost,
                        selectedCanvas: $selectedCanvas
                    )
                // choosing canvas to use with a host
                case .selectCanvas:
                    SelectCanvasView(
                        selectedHost: $selectedHost,
                        selectedCanvas: $selectedCanvas,
                        navToSessionActive: $navToSessionActive,
                        activeSheet: $activeSheet
                    )
                // choosing host to use with a canvas
                case .selectHost:
                    SelectHostView(
                        selectedHost: $selectedHost,
                        selectedCanvas: $selectedCanvas,
                        navToSessionActive: $navToSessionActive,
                        activeSheet: $activeSheet
                    )
                }
            }
            
            // because we can't navigate to an outer view from a sheet directly, this
            // allows us to activate navigation to the session page from the
            // SelectCanvas and SelectHost sheets
            .background(
                NavigationLink(
                    destination: SessionPageView(host: selectedHost, canvas: selectedCanvas),
                    isActive: $navToSessionActive
                ) {
                    EmptyView()
                }
            )
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct MainPageView_Previews: PreviewProvider {
    static var previews: some View {
        MainPageView().environment(
            \.managedObjectContext,
            PersistenceController.preview.container.viewContext
        )
    }
}
