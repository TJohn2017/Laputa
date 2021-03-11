//
//  MainPageList.swift
//  Laputa
//
//  Created by Daniel Guillen on 2/9/21.
//

import SwiftUI

struct MainPageList: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @Binding var displayHosts: Bool
    // the currently active sheet over MainPageView
    @Binding var activeSheet: ActiveSheet?
    
    // passed up to MainPageView where editing host/canvas info sheet is located
    @Binding var selectedHost: Host?
    @Binding var selectedCanvas: Canvas?
    
    var body: some View {
        return ScrollView {
            VStack {
                if (displayHosts) {
                    HostList(activeSheet: $activeSheet, selectedHost: $selectedHost)
                } else {
                    CanvasList(activeSheet: $activeSheet, selectedCanvas: $selectedCanvas)
                }
            }
        }
    }
    
}

struct MainPageList_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper()
    }
    
    struct PreviewWrapper: View {
        @State private var displayHosts: Bool = false
        @State private var activeSheet: ActiveSheet?
        
        var body: some View {
            MainPageList(
                displayHosts: $displayHosts,
                activeSheet: $activeSheet,
                selectedHost: .constant(nil),
                selectedCanvas: .constant(nil)
            ).environment(
                \.managedObjectContext,
                PersistenceController.preview.container.viewContext
            )
        }
    }
}
