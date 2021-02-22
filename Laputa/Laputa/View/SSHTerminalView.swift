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
    var host: HostInfo
    var ssh_session: SSHConnection
    var command_buffer = [UInt8]()
    
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
        //print("didReadData   data: \(message)")
        DispatchQueue.main.sync {
            self.feed(text: message)
        }
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
        do{
            try ssh_session.write(data: data)
        } catch {
            // TODO TJ figure out what error types we need to account for here
        }
    }
}
