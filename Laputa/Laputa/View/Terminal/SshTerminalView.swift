//
//  SshTerminalView.swift
//  Laputa
//
//  Created by Claire Mai on 2/9/21.
//

//
//  SshTerminalView.swift
//
//  The SSH Terminal View, connects the TerminalView with SSH
//
//  Created by Miguel de Icaza on 4/22/20.
//  Copyright © 2020 Miguel de Icaza. All rights reserved.
//

import Foundation
import UIKit
import SwiftTerm
import SwiftSH
import AudioToolbox

enum MyError : Error {
    case noValidKey(String)
    case general
}

///
/// Extends the AppTerminalView with elements for the connection
///
public class SshTerminalView: AppTerminalView, TerminalViewDelegate {
    public func hostCurrentDirectoryUpdate(source: TerminalView, directory: String?) {
        //
    }
    var data_sent: Bool // added this boolean
    var is_prompt: Bool // added this
    var host: Host
    var shell: SSHShell?
    var authenticationChallenge: AuthenticationChallenge!
    var sshQueue: DispatchQueue
    
    init (frame: CGRect, host: Host) throws
    {
        print ("3. created an sshterminal view")
        sshQueue = DispatchQueue.global(qos: .background)
        self.host = host
        self.data_sent = false
        self.is_prompt = false // this boolean doesn't work
        let useDefaultBackground = host.background == "default"
        super.init (frame: frame, useSharedTheme: host.style == "", useDefaultBackground: useDefaultBackground)
        
        if host.usePassword {
            if host.password == "" {
                authenticationChallenge = .byKeyboardInteractive(username: host.username, callback: passwordPrompt )
            } else {
                authenticationChallenge = .byPassword(username: host.username, password: host.password)
            }
        } /*else {
            if let sshKeyId = host.sshKey {
                if let sshKey = DataStore.shared.keys.first(where: { $0.id == sshKeyId }) {
                    authenticationChallenge = .byPublicKeyFromMemory(username: self.host.username,
                                                                     password: sshKey.passphrase,
                                                                     publicKey: Data (sshKey.publicKey.utf8),
                                                                     privateKey: Data (sshKey.privateKey.utf8))
                } else {
                    throw MyError.noValidKey ("The host references an SSH key that is no longer set")
                }
            } else {
                throw MyError.noValidKey ("The host does not have an SSH key associated")
            }
        }*/

        if !useDefaultBackground {
            updateBackground(background: host.background)
        }
        terminalDelegate = self
        let env = Environment(name: "LANG", variable: "en_US.UTF-8")
        // [Environment(name: "LANG", variable: "en_US.UTF-8")]
        shell = try? SSHShell(
                              host: host.hostname,
                              port: UInt16 (host.port & 0xffff),
                              environment: [env],
                              terminal: "xterm-256color")
        shell?.log.enabled = false
        //shell?.log.level = .error
        // This section is need to set up the callback functions that deal with displaying text
        //shell
        shell?.setCallbackQueue(queue: sshQueue)
        sshQueue.async {
            self.connect ()
        }
    }
  
    func getParentViewController () -> UIViewController? {
       var parentResponder: UIResponder? = self
       while parentResponder != nil {
           parentResponder = parentResponder?.next
           if let viewController = parentResponder as? UIViewController {
               return viewController
           }
       }
       return nil
    }
    
    var promptedPassword: String = ""
    var passwordTextField: UITextField?
    
    func passwordPrompt (challenge: String) -> String {
        //return "Granizado2!"
        guard let vc = getParentViewController() else {
            return ""
        }

        let semaphore = DispatchSemaphore(value: 0)
        
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: "Authetication challenge", message: challenge, preferredStyle: .alert)
            alertController.addTextField { [unowned self] (textField) in
                textField.placeholder = challenge
                textField.isSecureTextEntry = true
                self.passwordTextField = textField
            }
            alertController.addAction(UIAlertAction(title: "OK", style: .default) { [unowned self] _ in
                if let tf = self.passwordTextField {
                    self.promptedPassword = tf.text ?? ""
                }
                semaphore.signal()
                
            })
            vc.present(alertController, animated: true, completion: nil)
        }
        let _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        return promptedPassword
    }
    
    func connect()
    {
        print ("4. About to connect to claire's macbook pro")
        if let s = shell {
            s.withCallback { [unowned self] (data: Data?, error: Data?) in
                if let d = data {
                    let sliced = Array(d) [0...]
                    
                    // The first code causes problems, because the SSH library
                    // accumulates data, rather that sending it as it comes,
                    // so it can deliver blocks of 300k to 2megs of data
                    // which as far as the user is concerned, nothing happens
                    // while the terminal parsers proceses this.
                    //
                    // The solution was below, and it fed the data in chunks
                    // to the UI, but this caused the UI to not update chunks
                    // of the screen, for reasons that I do not understand yet.
                    #if true
                    if (data_sent) {
                        print ("data sent: \(String(bytes: sliced, encoding: .utf8))")
                        data_sent = false
                    } else if (is_prompt) { // data received
                        print ("prompt: \(String(bytes: sliced, encoding: .utf8))")
                        is_prompt = false
                    } else {
                        print ("data received: \(String(bytes: sliced, encoding: .utf8))")
                        is_prompt = true
                    }
                    
                    DispatchQueue.main.sync {
                        self.feed(byteArray: sliced)
                    }
                    #else
                    let blocksize = 1024
                    var next = 0
                    let last = sliced.endIndex
                    
                    while next < last {
                        
                        let end = min (next+blocksize, last)
                        let chunk = sliced [next..<end]
                    
                        DispatchQueue.main.sync {
                            print ("some data chunk: \(chunk)")
                            self.feed(byteArray: chunk)
                        }
                        next = end
                    }
                    #endif
                }
            }
            .connect()
            .authenticate(self.authenticationChallenge)
            .open { [unowned self] (error) in
                if let error = error {
                    self.feed(text: "[ERROR] \(error)\n")
                } else {
                    if self.host.hostKindGuess == "" {
                        if let guess = self.guessRemote(remoteBanner: s.remoteBanner) {
                            DispatchQueue.main.async {
                                 DataStore.shared.updateGuess (for: self.host, to: guess)
                            }
                        }
                    }
                    print("when is this called")
                    let t = self.getTerminal()
                    s.setTerminalSize(width: UInt (t.cols), height: UInt (t.rows))
                }
            }
        }
    }

    var remoteBannerToIcon : [String:String] = [
        "SSH-2.0-OpenSSH_7.4p1 Raspbian-10+deb9u7":"raspberry-pi",
        "SSH-2.0-OpenSSH_8.1": "apple", // 10.5
        "SSH-2.0-OpenSSH_7.9": "apple", // 10.4
        "Ubuntu":"ubuntu",
        "Debian":"debian",
        "Fedora":"fedora",
        "Windows": "windows",
        "Raspbian": "raspberri-pi",
        //"SSH-2.0-OpenSSH_7.9": "redhat",
    ]
    
    // Returns either the icon name to use or the empty string
    func guessRemote (remoteBanner: String?) -> String?
    {
        if remoteBanner == nil {
            return nil
        }
        if let kv = remoteBannerToIcon.first(where: { $0.key.localizedCaseInsensitiveContains(remoteBanner!) }) {
            return kv.value
        }
        return ""
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // TerminalViewDelegate conformance
    public func scrolled(source: TerminalView, position: Double) {
        //
    }
    
    public func setTerminalTitle(source: TerminalView, title: String) {
        //
    }
    
    public func sizeChanged(source: TerminalView, newCols: Int, newRows: Int) {
        if let s = shell {
            //print ("SshTerminalView setting remote terminal to \(newCols)x\(newRows)")
            s.setTerminalSize(width: UInt (newCols), height: UInt (newRows))
        }
    }
    
   /* public func bell (source: TerminalView)
    {
        switch settings.beepConfig {
        case .beep:
            // List of sounds: https://github.com/TUNER88/iOSSystemSoundsLibrary
            AudioServicesPlaySystemSound(SystemSoundID(1104))
        case .silent:
            break
        case .vibrate:
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.warning)
        }
    }*/
    
    // sends every character that is written in terminal one by one
    // i.e. called everytime you type in terminal
    public func send(source: TerminalView, data: ArraySlice<UInt8>) {
        
        shell?.write(Data (data)) { err in
            if let e = err {
                print ("Error sending \(e)")
            }
        }
        //  let string = String(bytes: data, encoding: .utf8)
        data_sent = true // added this
       
        /*
        if let data_string:String = String(data: data, encoding: .utf8) {
            print ("sent data: \(data_string)")
        } else {
            
        }*/
    }
}

