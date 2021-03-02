//
//  MainPageDetail.swift
//  Laputa
//
//  Created by Daniel Guillen on 2/13/21.
//

import SwiftUI

struct MainPageDetail: View {
    @Binding var displayHosts: Bool
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct MainPageDetail_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper()
    }
    
    struct PreviewWrapper: View {
        @State private var displayHosts: Bool = false
        
        var body: some View {
            let context = PersistenceController.preview.container.viewContext
            let newItem = Item(context: context)
            newItem.id = 100
            
            return MainPageDetail(
                displayHosts: $displayHosts
            )
        }
    }
}
