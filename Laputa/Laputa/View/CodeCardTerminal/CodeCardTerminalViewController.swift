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
    var contentString: String // String form containing all content to be displayed in this terminal view
    var width: CGFloat
    var height: CGFloat
    
    init(content: String, width: CGFloat, height: CGFloat) {
        self.contentString = content
        self.width = width
        self.height = height
        super.init(nibName:nil, bundle:nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Makes the terminal gui frame
    func makeFrame () -> CGRect
    {
        return CGRect (
            x: view.safeAreaInsets.left,
            y: view.safeAreaInsets.top,
            width: self.width,
            height: self.height)
    }
    
    // Given a new width and height as parameters sets the member variables accordingly
    // and recreates the frame so that the view size is updated.
    func updateDimensions(newWidth: CGFloat, newHeight: CGFloat) {
        self.width = newWidth
        self.height = newHeight
        self.view.frame = self.makeFrame()
        self.terminalView?.frame = self.view.frame
    }
    
    // Starts an instance of CodeCardTerminalView and provides the content to be displayed
    func createDummyTerminal() -> CodeCardTerminalView? {
        let tv = CodeCardTerminalView(content: contentString, frame: makeFrame())
        return tv
    }
    
    override func loadView() {
        super.loadView()
        self.view.frame = makeFrame()
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
