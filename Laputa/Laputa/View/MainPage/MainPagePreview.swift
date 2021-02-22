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
    @State var canvas: Canvas?
    
    var body: some View {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        
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
                Text("\(canvas!.wrappedTitle)")
                    .frame(width: 400.0, height: 200.0)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(Color.black)
                    .cornerRadius(10.0)
                Text("Created: \(dateFormatter.string(from: canvas!.wrappedDate))")
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
            
            let newCanvas = Canvas(context: context)
            newCanvas.id = UUID()
            newCanvas.dateCreated = Date()
            newCanvas.title = "Woohoo my favorite canvas"
            
            return MainPagePreview(
                canvas: newCanvas
            ).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
}
