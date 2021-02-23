//
//  SSHTerminalView.swift
//  Laputa
//
//  Created by Claire Mai on 2/10/21.
//

import Foundation
import SwiftTerm
import NMSSH

public class SSHTerminalView: TerminalView, TerminalViewDelegate, NMSSHChannelDelegate {
    // Constants
    let ReturnControlCode = UInt8(13)
        
    // Class variables
    var host: HostInfo
    var ssh_session: SSHConnection
    var command_buffer = [UInt8]()
    var shouldCatchResponse: Bool = false
    var lastReponse: String = ""
    
    init(host: HostInfo, frame: CGRect) {
        self.host = host
        
        self.ssh_session = SSHConnection(host: host.hostname, andUsername: host.username) //create ssh session
        super.init(frame: frame) // init function of TerminalView
        terminalDelegate = self
        self.connect()
    }
    
    private func addScrolling () {
        print("is scrolling enabled: \(self.isScrollEnabled)")
        
        //self.scrollViewDidScroll?(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Async function every time data is available to be displayed on terminal
    public func channel(_ channel: NMSSHChannel, didReadData message: String) {
        print("DATA RECEIVED: \(message)")
        
        // This message is a response from a command. Stash it so that the UI can work with it.
        if (shouldCatchResponse) {
            shouldCatchResponse = false
            print("CATCHING RESPONSE: \(message)")
            lastReponse = message
        }
        
        // TODO TJ: this check for the return character isn't working. It seems like it goes through send
        //          but doesn't actually show up in didReadData so for now I just put it there
//        if (message.count > 0 && message.last! == Character("\r")) {
//            shouldCatchResponse = true
//        }
        
        self.feed(text: message)
        
        //self.scrolled(source: self, position: <#T##Double#>)
    }
    
    // Async function every time an error is read
    public func channel(_ channel: NMSSHChannel, didReadError error: String) {
        print ("didReadError: \(error)")
    }
    
    func connect() {
        do {
            try ssh_session.connect(withAuth: host.usePassword, password: host.password)
            ssh_session.session.channel.delegate = self
        } catch SSHSessionError.authorizationFailed {
            let error = SSHSessionError.authorizationFailed
            self.feed(text: "[ERROR] \(error)")
        } catch {
            self.feed(text: "[ERROR] \(error)")
        }
    }
    
    public func scrolled(source: TerminalView, position: Double) {
        print ("scrolled, position: \(position)")
    }
    
    public func setTerminalTitle(source: TerminalView, title: String) {
        //
    }
    
    public func sizeChanged(source: TerminalView, newCols: Int, newRows: Int) {
        let resizeSuccess = ssh_session.requestTerminalSize(width: UInt(newCols), height: UInt(newRows))
        print(resizeSuccess)
        //source.sizeChanged(source: source.getTerminal())
        
    }
    
    public func hostCurrentDirectoryUpdate(source: TerminalView, directory: String?) {
        //
    }
    
    public func send(source: TerminalView, data: ArraySlice<UInt8>) {
        do {
            // If our line ends in a return character we may be executing a command, so prepare to catch the next
            // response for potential UI use.
            // TODO TJ: should we try to be more precise than this? for example, we are going to unnecessarily
            //          catch a ton of responses when doing things like using vim
            if (data[data.endIndex - 1] == ReturnControlCode) {
                shouldCatchResponse = true
            }
            try ssh_session.write(data: data)
        } catch {
            // TODO TJ figure out what error types we need to account for here
        }
    }
    
    // Getter function that returns teh last response instance variable
    public func lastResponse() -> String {
        return lastReponse
    }
}
