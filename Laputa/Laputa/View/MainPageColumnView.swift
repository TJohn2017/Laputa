//
//  MainPageColumnView.swift
//  Laputa
//
//  Created by Daniel Guillen on 2/11/21.
//

import SwiftUI

struct MainPageColumnView: View {
    @Binding var displayHosts: Bool
    @Binding var showingInputSheet: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            // Hosts Button.
            Button(action: {
                    if (!displayHosts) {
                        withAnimation {
                            displayHosts.toggle()
                        }
                    }
            }) {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Hosts")
                        .font(.largeTitle)
                        .fontWeight(.medium)
                        .foregroundColor(displayHosts ? Color.white : Color.gray)
                        .underline(displayHosts)
                    Spacer()
                        .frame(height: 10)
                    Button(action: {
                        showingInputSheet.toggle()
                    }) {
                        HStack {
                            Image(systemName: "plus.rectangle")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundColor(displayHosts ? Color.yellow : Color.gray)
                                .frame(height: 20)
                            Text("Add Host")
                                .foregroundColor(.gray)
                        }
                    }.disabled(!displayHosts)
                }
            }
            
            Spacer()
                .frame(height: 40)
            
            // Canvases Button.
            Button(action: {
                // Implement Canvas action.
                if (displayHosts) {
                    withAnimation {
                        displayHosts.toggle()
                    }
                }
            }) {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Canvases")
                        .font(.largeTitle)
                        .fontWeight(.medium)
                        .foregroundColor(!displayHosts ? Color.white : Color.gray)
                        .underline(!displayHosts)
                        .animation(.interpolatingSpring(stiffness: 90, damping: 15))
                    Spacer().frame(height: 10)
                    Button(action: {
                        showingInputSheet.toggle()
                    }) {
                        HStack {
                            Image(systemName: "plus.rectangle")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundColor(!displayHosts ? Color.yellow : Color.gray)
                                .frame(height: 20)
                            Text("Add Canvas")
                                .foregroundColor(.gray)
                        }
                    }.disabled(displayHosts)
                }
            }
        }
    }
}

struct MainPageColumnView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper()
    }
    
    struct PreviewWrapper: View {
        @State private var displayHosts: Bool = false
        @State private var showingInputSheet: Bool = false
        
        var body: some View {
            MainPageColumnView(
                displayHosts: $displayHosts,
                showingInputSheet: $showingInputSheet
            ).environment(
                \.managedObjectContext,
                PersistenceController.preview.container.viewContext
            )
        }
    }
}
