//
//  Host+CoreDataProperties.swift
//  Laputa
//
//  Created by Daniel Guillen on 3/6/21.
//
//

import Foundation
import CoreData


extension Host {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Host> {
        return NSFetchRequest<Host>(entityName: "Host")
    }

    @NSManaged public var host: String?
    @NSManaged public var name: String?
    @NSManaged public var password: String?
    @NSManaged public var port: String?
    @NSManaged public var privateKey: String?
    @NSManaged public var publicKey: String?
    @NSManaged public var username: String?
    @NSManaged public var authenticationTypeRawValue: String

    var authenticationType: AuthenticationType {
        set {
            authenticationTypeRawValue = newValue.rawValue
        }
        get {
            AuthenticationType(rawValue: authenticationTypeRawValue) ?? .password
        }
    }
}

extension Host : Identifiable {

}

enum AuthenticationType: String, CaseIterable, Identifiable {
    case password
    case publicPrivateKey

    var id: String { self.rawValue }
}
