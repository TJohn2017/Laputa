//
//  MainPagePreview.swift
//  Laputa
//
//  Created by Daniel Guillen on 2/13/21.
//

import SwiftUI

struct MainPagePreview: View {
    @Environment(\.managedObjectContext) private var viewContext

    @Binding var displayHosts: Bool
    var item: Item
    
    var body: some View {
        // Use this to toggle between different display configurations (if necessary).
        let color = displayHosts ? Color.red : Color.blue
        
        return Text("\(item.id)")
            .frame(width: 400.0, height: 200.0)
            .padding()
            .background(color)
            .cornerRadius(10.0)
    }
}

struct MainPagePreview_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper()
    }
    
    struct PreviewWrapper: View {
        @State private var displayHosts: Bool = false
        
        var body: some View {
            let context = PersistenceController.preview.container.viewContext
            let newItem = Item(context: context)
            newItem.id = 100
            
            return MainPagePreview(
                displayHosts: $displayHosts,
                item: newItem
            ).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
}
