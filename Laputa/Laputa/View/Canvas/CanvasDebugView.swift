//
//  CanvasDebugView.swift
//  Laputa
//
//  Created by Cynthia Jia on 2/21/21.
//

import SwiftUI

struct CanvasDebugView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(entity: CodeCard.entity(), sortDescriptors: [])
    var allCards: FetchedResults<CodeCard>
    
    var fetchRequest: FetchRequest<Canvas>
    var isSplit: Bool
    init(canvasId: UUID, isSplitView: Bool) {
        fetchRequest = FetchRequest<Canvas>(entity: Canvas.entity(), sortDescriptors: [], predicate: NSPredicate(format: "id == %@", canvasId as CVarArg))
        isSplit = isSplitView
    }
    var canvas: Canvas { fetchRequest.wrappedValue[0] }
    var cards: [CodeCard] { canvas.cardArray }

    var body: some View {
                
        func addExampleCard() {
            let newCard = CodeCard(context: viewContext)
            newCard.id = UUID()
            newCard.origin = canvas

            var maxZIndex = 0.0
            if !cards.isEmpty {
                maxZIndex = cards[0].zIndex + 1.0
            }
            newCard.zIndex = maxZIndex
            newCard.text = "\(newCard.id)\n\nx: \(newCard.locX), y: \(newCard.locY)\nzIndex: \(newCard.zIndex)"

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }

        func deleteCards() {
            withAnimation {
                for card in cards {
                    viewContext.delete(card)
                }

                do {
                    try viewContext.save()
                } catch {
                    // Replace this implementation with code to handle the error appropriately.
                    // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    let nsError = error as NSError
                    fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                }
            }
        }
        
        return ZStack {
            CanvasView(canvasId: canvas.id, isSplitView: isSplit)
            HStack {
                Button(action: addExampleCard) {
                    Text("Add card")
                }
                .padding(8)
                .foregroundColor(.white)
                .font(.title)
                .background(Color.green)
                .cornerRadius(5.0)

                Button(action: deleteCards) {
                    Text("Remove all cards")
                }
                .padding(8)
                .foregroundColor(.white)
                .font(.title)
                .background(Color.yellow)
                .cornerRadius(5.0)
            }
            .offset(x: 0, y: -UIScreen.main.bounds.height / 2  + 80)
        }
    }
}

struct CanvasDebugView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper()
    }
    
    struct PreviewWrapper: View {
        var body: some View {
            let context = PersistenceController.preview.container.viewContext
            let newCanvas = Canvas(context: context)
            newCanvas.id = UUID()
            newCanvas.dateCreated = Date()
            
            return CanvasDebugView(canvasId: newCanvas.id, isSplitView: false).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
}
