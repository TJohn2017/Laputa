//
//  MainPageView.swift
//  Laputa
//
//  Created by Daniel Guillen on 2/9/21.
//

import SwiftUI

// TODO:
// - Add a "+" add button --> triggers a menu that offers between canvas
//   and ssh host.
// - Clicking a Host --> should bring up a detail where you can choose
//    between saved canvases or prompts you to make a new one.
struct MainPageView: View {
    @State private var displayHosts: Bool = true
    @State private var showingInputSheet: Bool = false
    @State private var startSession: Bool = false
    
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
                    
                    MainPageList(displayHosts: $displayHosts)
                    
                    Spacer()
                    
                    NavigationLink(
                        destination: Text("Session"),
                        isActive: $startSession
                    ) {
                        EmptyView()
                    }
                }
            }
            .navigationBarTitle("")
            .navigationBarHidden(true)
            .edgesIgnoringSafeArea(.top) // Add to cover-up status bar.
            .sheet(
                isPresented: $showingInputSheet,
                onDismiss: {}
            ) {
                MainPageInputView(
                    displayHosts: $displayHosts,
                    showingInputSheet: $showingInputSheet
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
