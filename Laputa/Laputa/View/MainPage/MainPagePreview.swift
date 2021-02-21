//
//  MainPagePreview.swift
//  Laputa
//
//  Created by Daniel Guillen on 2/13/21.
//

import SwiftUI

struct MainPagePreview: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @State var host: Host?
    @State var item: Item?
    
    var body: some View {
        if (host != nil) {
            return VStack {
                Text("")
                    .frame(width: 400.0, height: 200.0)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(Color.black)
                    .cornerRadius(10.0)
                Text("\(host!.name!) | \(host!.host!) | \(host!.username!)")
                    .foregroundColor(Color.white)
            }.padding()
        } else {
            return VStack {
                Text("Canvas: \(item!.id)")
                    .frame(width: 400.0, height: 200.0)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(Color.black)
                    .cornerRadius(10.0)
                Text("Canvas Name #\(item!.id)")
                    .foregroundColor(Color.white)
            }.padding()
        }
    }
}

struct MainPagePreview_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper()
    }
    
    struct PreviewWrapper: View {
        
        var body: some View {
            let context = PersistenceController.preview.container.viewContext
            
            let newItem = Item(context: context)
            newItem.id = 100
            
            return MainPagePreview(
                item: newItem
            ).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
}
