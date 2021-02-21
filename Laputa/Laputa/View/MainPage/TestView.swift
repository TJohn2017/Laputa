//
//  TestView.swift
//  Laputa
//
//  Created by Daniel Guillen on 2/11/21.
//

import SwiftUI

struct DetailView: View {
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            Text("Hello, I'm the Detail")
            Button("Dismiss Me") {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}

struct TestView: View {
    @State private var displayHosts: Bool = false
    @State private var displayNewView: Bool = false

    var body: some View {
        
        
        VStack(alignment: .leading, spacing: 0) {
            Button(action: {}) {
                Text("Hosts")
                    .font(.largeTitle)
                    .fontWeight(.medium)
                    .foregroundColor(Color.black)
                    .underline(true)
            }
            Spacer()
                .frame(height: 10)
            HStack {
                Button(action: { }) {
                    Image(systemName: "plus.rectangle")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(Color.yellow)
                        .frame(height: 20)
                }
                Text("Click me!")
            }
        }
        /*
        NavigationView {
            VStack {
                Button("Show Detail") {
                    displayHosts.toggle()
                }
                .sheet(
                    isPresented: $displayHosts,
                    onDismiss: {
                        // will need additional logic handling here to handle case where
                        // a user wants back-out of sheet and NOT launch a session.
                        displayNewView = true
                    }) {
                    DetailView()
                }
                
                NavigationLink(destination: Text("New view!"), isActive: $displayNewView) {
                    EmptyView()
                }
            }
        }.navigationViewStyle(StackNavigationViewStyle())
        
        */
        

        
        /*
        NavigationView {
            ScrollView {
                ForEach(1..<20) {idx in
                    Text("\(idx)")
                        .frame(width: 50.0, height: 100.0)
                        .border(/*@START_MENU_TOKEN@*/Color.red/*@END_MENU_TOKEN@*/, width: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/)
                }
            }
            .navigationTitle("Hello")
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        */
        
        /*
        ZStack {
            Color.blue
            Text("Hello World")
                .foregroundColor(Color.white)
        }
        .edgesIgnoringSafeArea(.top)
        */
        
        /*
        ZStack {
            Color.black
            HStack {
                MainPageColumnView(displayHosts: $displayHosts)
                NavigationView {
                    ZStack {
                        Color.black
                        ScrollView {
                            VStack {
                                ForEach(1..<20) { idx in
                                    Text("\(idx)")
                                        .frame(width: 500.0, height: 250.0)
                                        .padding()
                                        .background(Color.white)
                                        .cornerRadius(10.0)
                                }
                            }
                        }
                    }
                    .navigationTitle("")
                    .navigationBarHidden(true)
                    .edgesIgnoringSafeArea(.top)

                }
                .navigationViewStyle(StackNavigationViewStyle())

            }
        }
        .edgesIgnoringSafeArea(.top)
    */
        

    }
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}
