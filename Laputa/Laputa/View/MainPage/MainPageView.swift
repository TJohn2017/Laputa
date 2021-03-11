//
//  MainPageView.swift
//  Laputa
//
//  Created by Daniel Guillen on 2/9/21.
//

import SwiftUI

struct MainPageView: View {
    @State private var displayHosts: Bool = true
    @State private var showingInputSheet: Bool = false
    @State var selectedCanvas: Canvas? = nil
    @State var selectedHost: Host? = nil
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black
                HStack {
                    MainPageColumnView(
                        displayHosts: $displayHosts,
                        showingInputSheet: $showingInputSheet
                    )
                    .padding(.leading, 40)
                    
                    Spacer()
                    
                    MainPageList(displayHosts: $displayHosts,
                                 showingInputSheet: $showingInputSheet,
                                 selectedHost: $selectedHost,
                                 selectedCanvas: $selectedCanvas)
                }
            }
            .navigationBarTitle("")
            .navigationBarHidden(true)
            .edgesIgnoringSafeArea(.top) // Add to cover-up status bar.
            .sheet(
                isPresented: $showingInputSheet,
                onDismiss: {
                    selectedHost = nil
                    selectedCanvas = nil
                }
            ) {
                MainPageInputView(
                    displayHosts: $displayHosts,
                    showingInputSheet: $showingInputSheet,
                    selectedHost: $selectedHost,
                    selectedCanvas: $selectedCanvas
                )
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct MainPageView_Previews: PreviewProvider {
    static var previews: some View {
        MainPageView().environment(
            \.managedObjectContext,
            PersistenceController.preview.container.viewContext
        )
    }
}
