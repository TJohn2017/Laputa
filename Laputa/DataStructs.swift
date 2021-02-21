//
//  DataStructs.swift
//  Laputa
//
//  Created by Claire Mai on 2/10/21.
//

import Foundation

struct Host: Codable, Identifiable {
    var id = UUID()
    var alias: String = ""
    var hostname: String = ""
    var port: Int = 22
    var username: String = ""
    var usePassword: Bool = true
    var password: String = ""
    var environmentVariables: [String] = [] // EX: Environment(name: "LANG", variable: "en_US.UTF-8")
   
    init(alias:String, hostname:String, username:String, usePassword:Bool, password:String){
        self.alias = alias
        self.hostname = hostname
        self.username = username
        self.usePassword = usePassword
        self.password = password
    }
}
