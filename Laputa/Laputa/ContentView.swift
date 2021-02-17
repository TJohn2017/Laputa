//
//  ContentView.swift
//  Laputa
//
//  Created by Tyler Johnson on 2/2/21.
//

import SwiftUI
import CoreData

/*
 - MainPageInputHost
    - Define Host entity --> Ask Claire what info is needed to SSH
    - Core Data functionality: Needs to add new host to your data
 
  - MainPageList:
    - Add initial empty tab with "plus" sign to add a canvas or host (when no items are present)
    - Lower the starting height of the list so it doesn't start immediately from the very top.
    - Replace Navigation Link w/ a menu / text-input / sheet-popup button:
        > Blank Canvas:
            + Enter name
            + "Picker" View for selecting corresponding SSH Host
        > Canvas:
            + "Picker" View for selecting corresponding SSH Host
        > Blank SSH HOST:
            + Enter ssh host info
            + "Picker" View for selecting corresponding Blank Canvas or other Canvas
        > SSH Host:
            + "Picker" View for selecting corresponding Blank Canvas or other Canvas
        >>>> After final selection should execute a navigationLink to a SessionView
 
  - MainPagePreview:
    - Add a descriptive text box underneath or besides the box-preview:
        > Canvas: contains a title ("name")
        > Host: bunch of host info similar to the other apps.
 
 - MainPageInputCanvas
   - Reach out w/ Cynthia to define Canvas entity
   - Core Data functionality: Needs to add a new canvas to your data
 
 - FUTURE:
    - Replace "Add Canvas" w/ something like "Blank Canvas" that launches
      one directly into a new canvas.
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
