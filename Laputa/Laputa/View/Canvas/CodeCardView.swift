//
//  CodeCard.swift
//  Laputa
//
//  Created by Cynthia Jia on 2/8/21.
//

import SwiftUI
import CoreData

struct CodeCardView: View {
    var codeCard : CodeCard
    // Should be one higher than the largest zIndex available in the
    // stack of code cards
    @Binding var maxZIndex: Double
    
    @Environment(\.managedObjectContext) private var viewContext
    
    // set up interaction states for conditional logic later.
    enum DragState {
        case inactive // no interaction
        case dragging(translation: CGSize) // dragging to a new position
        
        var translation: CGSize {
            switch self {
            case .inactive:
                return .zero
            case .dragging(let translation):
                return translation
            }
        }
        
        var isDragging: Bool {
            switch self {
            case .inactive:
                return false
            case .dragging:
                return true
            }
        }
    }
    
    @GestureState var dragState = DragState.inactive
    @State var viewState = CGSize.zero
    // Whether or not a user is currently able to delete a card
    @State var deleting = false
    // Size state variables
    @State var width: CGFloat = 500
    @State var height: CGFloat = 500
    
    // Sets initial card position saved in CoreData
    func setInitialOffset() {
        self.viewState.width = CGFloat(codeCard.locX)
        self.viewState.height = CGFloat(codeCard.locY)
    }
    
    // Sets code card zIndex to the max, bringing
    // it to the top, and saves to CoreData
    func updateCardZIndex() {
        viewContext.performAndWait {
            codeCard.zIndex = maxZIndex
            try? viewContext.save()
        }
    }
    
    // Saves card position in CoreData
    func updateCardPosition() {
        let newLocX = Double(viewState.width)
        let newLocY = Double(viewState.height)
        
        viewContext.performAndWait {
            codeCard.locX = newLocX
            codeCard.locY = newLocY
            try? viewContext.save()
        }
    }
    
    // After pressing for min duration,
    // a button will appear to delete card
    var longPressDelete: some Gesture {
        LongPressGesture(minimumDuration: 0.5)
            .onChanged { _ in
                updateCardZIndex()
            }
            .onEnded { finished in
                if finished {
                    self.deleting.toggle()
                }
            }
    }
    
    
    // Used for when user taps the background to
    // dismiss the delete button
    var dismissDelete: some Gesture {
        TapGesture()
            .onEnded { _ in
                deleting = false
            }
    }
    
    var body: some View {
        
        let drag = DragGesture()
            .onChanged { _ in
                updateCardZIndex()
            }
            .updating($dragState) { value, state, transaction in
                state = .dragging(translation: value.translation)
            }
            .onEnded { value in
                self.viewState.width += value.translation.width
                self.viewState.height += value.translation.height
                maxZIndex += 1
                
                updateCardPosition()
            }
        
        return
            ZStack {
                // A transparent rectangle to highlight card to delete.
                // If tapped, it will dismiss the delete option.
                if self.deleting {
                    Rectangle()
                        .ignoresSafeArea()
                        .foregroundColor(Color(white: 1).opacity(0.5))
                        .gesture(dismissDelete)
                }
                HStack() {
                    CodeCardTerminal(content: codeCard.wrappedText, width: width, height: height)
                        .border(self.deleting ? .red : Color.white)
                    if self.deleting {
                        Button(action: {
                            viewContext.delete(codeCard)
                            do {
                                try viewContext.save()
                                print("Code card deleted.")
                            } catch {
                                print(error.localizedDescription)
                            }
                        }) {
                            Text("Delete")
                                .padding()
                                .foregroundColor(Color.white)
                                .background(Color.red.opacity(0.9))
                                .cornerRadius(10)
                        }
                    }
                }
                .offset(
                    x: CGFloat(codeCard.locX) + dragState.translation.width,
                    y: CGFloat(codeCard.locY) + dragState.translation.height
                )
                .gesture(longPressDelete)
                // don't allow dragging while delete button is visible
                .gesture(self.deleting ? nil : drag)
                .shadow(radius: dragState.isDragging ? 8 : 0)
                .onAppear(perform: setInitialOffset)
                .frame(width: width, height: height, alignment: .center)
            }
            .zIndex(codeCard.zIndex)
    }
}

struct CodeCardView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper()
    }
    
    struct PreviewWrapper: View {
        var body: some View {
            let context = PersistenceController.preview.container.viewContext
            let newCard = CodeCard(context: context)
            newCard.id = UUID()
            newCard.text = "Desktop\nDownloads\nLol\nNICE\nZippityZooZah"
            
            return CodeCardView(
                codeCard: newCard,
                maxZIndex: .constant(0.0)
            ).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
}
