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
    var ssh_session: SSHConnection?
    var command_buffer = [UInt8]()
    // TODO TJ take these out if we can't use them
//    var shouldCatchResponse: Bool = false
//    var lastResponse: String = ""
    
    init(connection: SSHConnection?, frame: CGRect) {
        super.init(frame: frame) // init function of TerminalView
        self.ssh_session = connection
        connection?.session.channel.delegate = self // Allows us to handle delegate functions for fetching/sending data
        terminalDelegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Async function every time data is available to be displayed on terminal
    public func channel(_ channel: NMSSHChannel, didReadData message: String) {
        DispatchQueue.main.sync {
            self.feed(text: message)
        }
    }
    
    // Async function every time an error is read
    public func channel(_ channel: NMSSHChannel, didReadError error: String) {
        print ("didReadError: \(error)")
    }
    
    public func scrolled(source: TerminalView, position: Double) {}
    
    public func setTerminalTitle(source: TerminalView, title: String) {}
    
    public func sizeChanged(source: TerminalView, newCols: Int, newRows: Int) {
        let resizeSuccess = ssh_session?.requestTerminalSize(width: UInt(newCols), height: UInt(newRows))
        print(resizeSuccess ?? "Resized terminal.")
    }
    
    public func hostCurrentDirectoryUpdate(source: TerminalView, directory: String?) {}
    
    public func send(source: TerminalView, data: ArraySlice<UInt8>) {
        do {
            try ssh_session?.write(data: data)
        } catch {
            // TODO TJ figure out what error types we need to account for here
        }
    }
    
    // Getter function that returns teh last response instance variable
    public func lastResponse() -> String {
        return ssh_session?.session.channel.lastResponse ?? ""
    }
    
    public func isConnected() -> Bool {
        if (ssh_session != nil) {
            return ssh_session!.isConnected()
        } else {
            return false
        }
    }
}
