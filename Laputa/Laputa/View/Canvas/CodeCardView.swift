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
    @Binding var maxZIndex: Double
    
    @Environment(\.managedObjectContext) private var viewContext
    
    // set up interaction states for conditional logic later.
    enum DragState {
        case inactive // no interaction
        case pressing // long press in progress
        case dragging(translation: CGSize) // dragging to a new position
        
        var translation: CGSize {
            switch self {
            case .inactive, .pressing:
                return .zero
            case .dragging(let translation):
                return translation
            }
        }
        
        var isActive: Bool {
            switch self {
            case .inactive:
                return false
            case .pressing, .dragging:
                return true
            }
        }
        
        var isDragging: Bool {
            switch self {
            case .inactive, .pressing:
                return false
            case .dragging:
                return true
            }
        }
    }
    
    @GestureState var dragState = DragState.inactive
    @State var viewState = CGSize.zero
    
    var body: some View {

        let minimumLongPressDuration = 0.05
        let longPressDrag = LongPressGesture(minimumDuration: minimumLongPressDuration)
            .sequenced(before: DragGesture())
            .onChanged { _ in
                updateCardZIndex()
            }
            .updating($dragState) { value, state, transaction in
                switch value {
                // Long press begins.
                case .first(true):
                    state = .pressing
                // Long press confirmed, dragging may begin.
                case .second(true, let drag):
                    state = .dragging(translation: drag?.translation ?? .zero)
                // Dragging ended or the long press cancelled.
                default:
                    state = .inactive
                }
            }
            .onEnded { value in
                guard case .second(true, let drag?) = value else { return }
                self.viewState.width += drag.translation.width
                self.viewState.height += drag.translation.height
                maxZIndex += 1
                
                updateCardPosition()
            }
        
        func updateCardPosition() {
            let newLocX = Double(viewState.width)
            let newLocY = Double(viewState.height)
            
            viewContext.performAndWait {
                codeCard.locX = newLocX
                codeCard.locY = newLocY
                try? viewContext.save()
            }
        }
        
        func updateCardZIndex() {
            viewContext.performAndWait {
                codeCard.zIndex = maxZIndex
                try? viewContext.save()
            }
        }
        
        func setInitialOffset() {
            self.viewState.width = CGFloat(codeCard.locX)
            self.viewState.height = CGFloat(codeCard.locY)
        }
        
        return ZStack{
            Text(codeCard.wrappedText)
                .padding(20)
                .border(Color.white)
                .foregroundColor(.white)
                .background(Color(red: 0.2, green: 0.2, blue: 0.2, opacity: 1.0))
                .font(.custom("Menlo-Regular", size: 12))
        }
        .offset(
            x: CGFloat(codeCard.locX) + dragState.translation.width,
            y: CGFloat(codeCard.locY) + dragState.translation.height
        )
        .shadow(radius: dragState.isActive ? 8 : 0)
        .animation(.linear(duration: minimumLongPressDuration))
        .gesture(longPressDrag)
        .onAppear(perform: setInitialOffset)
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
