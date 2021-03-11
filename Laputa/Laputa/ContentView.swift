//
//  ContentView.swift
//  Laputa
//
//  Created by Tyler Johnson on 2/2/21.
//

import SwiftUI
import UIKit
import CoreData

/*
  - MainPageList:
    - TODO: Add initial empty tab with "plus" sign to add a canvas or host (when no items are present)
 
    - TODO: Lower the starting height of the list so it doesn't start immediately from the very top.
 
 - MainPagePreview:
    - TODO: Add "***" button to menu popup that allows to delete
      entities or update entity in the mainPageInput[Host/Canvas]
    - TODO: Add delete functionality to remove entity optionally.
 
 - InputCanvasView
   - TODO: Merge Canvas core data functionality.
 */

struct ContentView: View {
    init() {
        // this is not the same as manipulating the proxy directly
        let appearance = UINavigationBarAppearance()
        
        // this only applies to big titles
        appearance.largeTitleTextAttributes = [
            .font : UIFont.systemFont(ofSize: 20),
            NSAttributedString.Key.foregroundColor : UIColor.black
        ]
        // this only applies to small titles
        appearance.titleTextAttributes = [
            .font : UIFont.systemFont(ofSize: 20),
            NSAttributedString.Key.foregroundColor : UIColor.black
        ]
        
        //In the following two lines you make sure that you apply the style for good
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().standardAppearance = appearance
        
        // This property is not present on the UINavigationBarAppearance
        // object for some reason and you have to leave it til the end
        UINavigationBar.appearance().tintColor = .black
    }
    
    var body: some View {
        MainPageView()
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}


