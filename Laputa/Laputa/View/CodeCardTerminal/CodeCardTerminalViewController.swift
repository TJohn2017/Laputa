//
//  CodeCardTerminalViewController.swift
//  Laputa
//
//  Created by Tyler Johnson on 3/2/21.
//

import Foundation
import SwiftUI

class CodeCardTerminalViewController: UIViewController {
    var terminalView: CodeCardTerminalView?
    var contentString: String
    
    init(content: String) {
        self.contentString = content
        super.init(nibName:nil, bundle:nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Makes the terminal gui frame
    func makeFrame () -> CGRect
    {
//        let view_height = view.frame.height - view.safeAreaInsets.bottom - view.safeAreaInsets.top
        
//        return CGRect (
//            x: view.safeAreaInsets.left,
//            y: view.safeAreaInsets.top,
//            width: view.frame.width - view.safeAreaInsets.left - view.safeAreaInsets.right,
//            height: view_height)
        return CGRect (
            x: view.safeAreaInsets.left,
            y: view.safeAreaInsets.top,
            width: 100,
            height: 100)
    }
    
    
    // Starts an instance of CodeCardTerminalView and provides the content to be displayed
    func createDummyTerminal() -> CodeCardTerminalView? {
        let tv = CodeCardTerminalView(content: contentString, frame: makeFrame())
        return tv
    }
    
    // Loads terminal gui into the view
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // start ssh session and add it ot the view
        terminalView = createDummyTerminal()
        guard let t = terminalView else {
            return
        }
        self.terminalView = t
       
        t.frame = view.frame
        view.addSubview(t)
    }
}
