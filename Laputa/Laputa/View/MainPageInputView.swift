//
//  MainPageInputView.swift
//  Laputa
//
//  Created by Daniel Guillen on 2/16/21.
//

import SwiftUI

struct MainPageInputView: View {
    @Binding var displayHosts: Bool
    @Binding var showingInputSheet: Bool
    
    var body: some View {
        if (displayHosts) {
            MainPageInputHost()
        } else {
            MainPageInputCanvas()
        }
    }
}

struct MainPageInputView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper()
    }
    
    struct PreviewWrapper: View {
        @State private var displayHosts: Bool = false
        @State private var showingInputSheet: Bool = false
        
        var body: some View {
            MainPageInputView(
                displayHosts: $displayHosts,
                showingInputSheet: $showingInputSheet
            ).environment(
                \.managedObjectContext,
                PersistenceController.preview.container.viewContext
            )
        }
    }
}
