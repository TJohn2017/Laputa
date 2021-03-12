//
//  MainPageHeaderView.swift
//  Laputa
//
//  Created by Cynthia Jia on 3/10/21.
//

import SwiftUI

struct MainPageHeaderView: View {
    @Binding var displayHosts: Bool
    @Binding var activeSheet: ActiveSheet?
    @Binding var selectedHost: Host?
    @Binding var selectedCanvas: Canvas?
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.white)
                .frame(height: 150)
            ZStack {
                HStack {
                    Image("IconCircular")
                        .resizable()
                        .frame(width: 100, height: 100, alignment: .center)
                        .padding(.leading, 30)
                    Spacer()
                    
                    // New host or canvas
                    Button(action: {
                        activeSheet = .inputSheet
                        selectedHost = nil
                        selectedCanvas = nil
                    }) {
                        Image(systemName: "plus.circle")
                            .font(.largeTitle)
                            .foregroundColor(
                                displayHosts ? Color("HostMain") : Color("CanvasMain")
                            )
                    }
                    .padding(.trailing, 30)
                }
                
                HStack(alignment: .center) {
                    // Hosts Button.
                    Button(action: {
                        if (!displayHosts) {
                            displayHosts.toggle()
                        }
                    }) {
                        
                        Text("Hosts")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(displayHosts ? Color("HostMain") : Color.gray)
                        
                    }
                    Spacer()
                        .frame(width: 75)
                    
                    // Canvases Button.
                    Button(action: {
                        if (displayHosts) {
                            displayHosts.toggle()
                        }
                    }) {
                        
                        Text("Canvases")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(!displayHosts ? Color("CanvasMain") : Color.gray)
                            .animation(.interpolatingSpring(stiffness: 90, damping: 15))
                        
                    }
                }
            }
            
        }
    }
}

struct MainPageHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper()
    }
    
    struct PreviewWrapper: View {
        @State private var displayHosts: Bool = false
        @State private var activeSheet: ActiveSheet?
        
        var body: some View {
            MainPageHeaderView(
                displayHosts: $displayHosts,
                activeSheet: $activeSheet,
                selectedHost: .constant(nil),
                selectedCanvas: .constant(nil)
            ).environment(
                \.managedObjectContext,
                PersistenceController.preview.container.viewContext
            )
        }
    }
}
