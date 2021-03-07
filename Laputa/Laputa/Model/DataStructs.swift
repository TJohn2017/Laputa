//
//  DataStructs.swift
//  Laputa
//
//  Created by Claire Mai on 2/10/21.
//

import Foundation


struct HostInfo: Codable, Identifiable {
    var id = UUID()
    var alias: String = ""
    var hostname: String = ""
    var port: Int = 22
    var username: String = ""
    var authType: AuthenticationType = AuthenticationType.password
    var password: String = ""
    var publicKey: String = ""
    var privateKey: String = ""
    var privateKeyPassword: String = ""
    var environmentVariables: [String] = [] // EX: Environment(name: "LANG", variable: "en_US.UTF-8")
   
    init(alias:String, username:String, hostname:String, authType: AuthenticationType, password:String, publicKey:String, privateKey:String, privateKeyPassword:String){
        self.alias = alias
        self.username = username
        self.hostname = hostname
        self.authType = authType
        self.password = password
        self.publicKey = publicKey
        self.privateKey = privateKey
        self.privateKeyPassword = privateKeyPassword
    }
}
