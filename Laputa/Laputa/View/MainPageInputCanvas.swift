//
//  MainPageInputCanvas.swift
//  Laputa
//
//  Created by Daniel Guillen on 2/16/21.
//

import SwiftUI

struct MainPageInputCanvas: View {
    @State var name: String = ""
    
    var body: some View {
        Form {
            Section(header: Text("Canvas Info")) {
                HStack {
                    Text("Name")
                    TextField("Required", text: $name).multilineTextAlignment(.trailing)
                }
            }
            
            Button(action: {
                // View needs to set
            }) {
                Text("Add Canvas")
            }
        }
    }
}

struct MainPageInputCanvas_Previews: PreviewProvider {
    static var previews: some View {
        MainPageInputCanvas()
    }
}
