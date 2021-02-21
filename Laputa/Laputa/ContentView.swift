//
//  ContentView.swift
//  Laputa
//
//  Created by Tyler Johnson on 2/2/21.
//

import SwiftUI
import CoreData

/*
  - MainPageList:
    - TODO: Add initial empty tab with "plus" sign to add a canvas or host (when no items are present)
 
    - TODO: Lower the starting height of the list so it doesn't start immediately from the very top.
 
 - MainPagePreview:
    - TODO: Add delete functionality to remove entity optionally.
 
 - MainPageInputCanvas
   - TODO: Merge Canvas core aata functionality.
 */

struct ContentView: View {
    var body: some View {
        MainPageView()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
