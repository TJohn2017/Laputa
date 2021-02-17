//
//  MainPageList.swift
//  Laputa
//
//  Created by Daniel Guillen on 2/9/21.
//

import SwiftUI

struct MainPageList: View {
    // TODO:
    //  - Will need to load viewContext + FetchRequest to retrieve list of canvases and hosts.
    // - Can add a sort predicate in sortDescriptors list.
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        entity: Item.entity(),
        sortDescriptors: [],
        predicate: NSPredicate(format: "id >= 0")
    )
    var items: FetchedResults<Item>
    
    @Binding var displayHosts: Bool
    
    var body: some View {
        // TODO: toggle between fetched canvases and fetched ssh hosts.
        let listItems = displayHosts ? items : items
        
        
        return ScrollView {
            VStack {
                ForEach(listItems) { item in
                    NavigationLink(destination: MainPageDetail(displayHosts: $displayHosts)) {
                        MainPagePreview(displayHosts: $displayHosts, item: item)
                    }
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
        
        var body: some View {
            MainPageList(displayHosts: $displayHosts).environment(
                \.managedObjectContext,
                PersistenceController.preview.container.viewContext
            )
        }
    }
}
