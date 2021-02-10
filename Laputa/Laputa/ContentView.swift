//
//  ContentView.swift
//  Laputa
//
//  Created by Tyler Johnson on 2/2/21.
//

import SwiftUI
import CoreData

struct ContentView: View {
    var body: some View {
        DrawingView(isDrawing: false)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
