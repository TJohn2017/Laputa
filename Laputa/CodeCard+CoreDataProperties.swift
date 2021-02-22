//
//  CodeCard+CoreDataProperties.swift
//  Laputa
//
//  Created by Cynthia Jia on 2/19/21.
//
//

import Foundation
import CoreData


extension CodeCard {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CodeCard> {
        return NSFetchRequest<CodeCard>(entityName: "CodeCard")
    }

    @NSManaged public var id: UUID
    @NSManaged public var locX: Double
    @NSManaged public var locY: Double
    @NSManaged public var zIndex: Double
    @NSManaged public var text: String?
    @NSManaged public var origin: Canvas?
    
    public var wrappedText: String {
        text ?? ""
    }

}

extension CodeCard : Identifiable {

}
