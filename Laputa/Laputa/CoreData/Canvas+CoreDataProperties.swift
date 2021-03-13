//
//  Canvas+CoreDataProperties.swift
//  Laputa
//
//  Created by Cynthia Jia on 2/19/21.
//
//  This resource is very helpful: https://www.hackingwithswift.com/books/ios-swiftui/one-to-many-relationships-with-core-data-swiftui-and-fetchrequest

import Foundation
import CoreData


extension Canvas {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Canvas> {
        return NSFetchRequest<Canvas>(entityName: "Canvas")
    }

    @NSManaged public var id: UUID
    @NSManaged public var dateCreated: Date
    @NSManaged public var title: String?
    @NSManaged public var cards: NSSet?
    @NSManaged public var drawingData: Data?
    @NSManaged public var locX: Double
    @NSManaged public var locY: Double
    @NSManaged public var magnification: Double
    
    public var wrappedTitle: String {
        title ?? "Untitled canvas"
    }
    
    public var cardArray: [CodeCard] {
        let set = cards as? Set<CodeCard> ?? []
        
        return set.sorted(by: {
            // TODO: investigate why the sorting seems to get messed up after a few card additions
            $0.zIndex > $1.zIndex
        })
    }
    
    public var wrappedDate: Date {
        dateCreated ?? Date()
    }
    
    public var wrappedMagnification: Double {
        return magnification == 0 ? 1.0 : magnification
    }

}

// MARK: Generated accessors for cards
extension Canvas {

    @objc(addCardsObject:)
    @NSManaged public func addToCards(_ value: CodeCard)

    @objc(removeCardsObject:)
    @NSManaged public func removeFromCards(_ value: CodeCard)

    @objc(addCards:)
    @NSManaged public func addToCards(_ values: NSSet)

    @objc(removeCards:)
    @NSManaged public func removeFromCards(_ values: NSSet)

}

extension Canvas : Identifiable {

}
