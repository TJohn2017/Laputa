//
//  TerminalComponentView.swift
//  Laputa
//
//  Created by Claire Mai on 2/11/21.
//

import SwiftUI

struct TerminalComponentView: View {
    var host: HostInfo
    
    init(host: HostInfo) {
        self.host = host
    }
    
    var body: some View {
        SwiftUITerminal(host: host)
            .padding([.top, .leading, .bottom], 1.0)
            .border(/*@START_MENU_TOKEN@*/Color.yellow/*@END_MENU_TOKEN@*/, width: /*@START_MENU_TOKEN@*/3/*@END_MENU_TOKEN@*/)
    }
}

struct TerminalComponentView_Previews: PreviewProvider {
    static var previews: some View {
        TerminalComponentView(host: HostInfo(alias:"claire's laptop", hostname:"192.168.1.11", username:"clairemai", usePassword:true, password:"macaron"))
    }
}
