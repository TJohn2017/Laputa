//
//  TerminalWindowView.swift
//  Laputa
//
//  Created by Claire Mai on 2/9/21.
//

import SwiftUI

struct TerminalWindowView: View {
    var host: Host
    init() {
        self.host = Host(alias: "Claire MacPro", hostname: "192.168.1.11", usePassword: true, username: "clairemai", password: "macaron", lastUsed: Date ())
    }
    var body: some View {
        SwiftUITerminal(host: host, createNew: true, interactive: true).navigationBarTitle (Text (host.alias), displayMode: .inline)
    }
}

struct TerminalWindowView_Previews: PreviewProvider {
    static var previews: some View {
        TerminalWindowView()
    }
}
