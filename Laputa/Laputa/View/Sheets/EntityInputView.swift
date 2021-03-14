//
//  EntityInputView.swift
//  Laputa
//
//  Created by Daniel Guillen on 2/16/21.
//

import SwiftUI

struct EntityInputView: View {
    @Binding var displayHosts: Bool
    @Binding var activeSheet: ActiveSheet?
    @Binding var selectedHost: Host?
    @Binding var selectedCanvas: Canvas?
    
    var body: some View {
        if (displayHosts) {
            InputHostView(activeSheet: $activeSheet, parentActiveSheet: .constant(nil), selectedHost: $selectedHost)
        } else {
            InputCanvasView(activeSheet: $activeSheet, parentActiveSheet: .constant(nil), selectedCanvas: $selectedCanvas)
        }
    }
}

struct EntityInputView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper()
    }
    
    struct PreviewWrapper: View {
        @State private var displayHosts: Bool = false
        @State var activeSheet: ActiveSheet?
        
        var body: some View {
            EntityInputView(
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
