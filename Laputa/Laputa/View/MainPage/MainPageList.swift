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
        entity: Item.entity(),
        sortDescriptors: [],
        predicate: NSPredicate(format: "id >= 0")
    )
    var items: FetchedResults<Item>
    
    @FetchRequest(
        entity: Host.entity(),
        sortDescriptors: []
    )
    var hosts: FetchedResults<Host>
    
    @Binding var displayHosts: Bool
    
    var body: some View {

        return AnyView(ScrollView {
            VStack {
                if (displayHosts) {
                    ForEach(hosts) { host in
                        NavigationLink(destination: SessionPageView(hostPresent: true, canvasPresent: false, host: host)) {
                            MainPagePreview(host: host)
                        }
                    }
                } else {
                    ForEach(items) { item in
                        NavigationLink(destination: SessionPageView(hostPresent: true, canvasPresent: false, canvas: item)) {
                            MainPagePreview(item: item)
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
