//
// The SSHConnection class maintains a single open SSH connection.
// It provides the API for users to create, end, and communicate over
// an SSH connection.
//
// SSHConnection.swift
//  Laputa
//
//  Created by Tyler Johnson on 2/10/21.
//

import Foundation
import NMSSH

enum SSHSessionError: Error {
    case authorizationFailed
}

class SSHConnection {
    var session: NMSSHSession // This is the underlying SSH connection managed by NMSSH
    
    init(host: String, andUsername: String) {
        session = NMSSHSession(host: host, andUsername: andUsername)
    }
    
    // TODO TJ comment
    func connect(withAuth:Bool, password: String?) throws {
        if (session.connect()) {
            // Must authenticate before getting a terminal
            if (withAuth) {
                session.authenticate(byPassword: password ?? "") // If they did not provide a password try none.
                if (!session.isAuthorized) {
                    session.disconnect()
                    throw SSHSessionError.authorizationFailed
                }
            }

            session.channel.requestPty = true // Request a pseudo-terminal before command execution
            // TODO TJ we could opt to not hardcode this in order to let user's dictate
            session.channel.ptyTerminalType = NMSSHChannelPtyTerminal.xterm // Request that our pseuo-terminal is xterm
            
            // If we ever want to establish multiple shells at one time on one connection we will likely need to
            // abstract this and put it in its own function
            try session.channel.startShell()
        } // TODO TJ. If we fail authentication do we need to manually disconnect?
        else {
            print("connect failed")
        }
    }
    
    // TODO TJ comment
    func disconnect() {
        session.channel.closeShell()
        session.disconnect()
    }
    
    // TODO TJ comment. Also, does this handle argument parsing for us?
    func executeCommand(command: String) -> String {
        let errorPointer: NSErrorPointer = nil
        let result = session.channel.execute(command, error: errorPointer)
//        print(result)
        return result
    }
    
    // TODO TJ comment
    func write(data: ArraySlice<UInt8>) throws {
        let letter = String(bytes: data, encoding: .utf8)
        if (letter != nil) {
            let new_data = Data(letter!.utf8)
            try session.channel.write(new_data)
        }
    }
    
    // TODO TJ comment
    func requestTerminalSize(width: UInt, height: UInt) -> Bool {
        return session.channel.requestSizeWidth(width, height: height)
    }
}

