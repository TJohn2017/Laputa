//
//  CodeCardTerminal.swift
//  Laputa
//
//  Created by Tyler Johnson on 3/2/21.
//

import SwiftUI
import SwiftTerm

public class CodeCardTerminalView: TerminalView, TerminalViewDelegate {    
    // TODO:
    // - How can we handle scrolling in the dummy view? As things are these need to fit the entire piece of content on screen
    
    // Class variables
    var command_buffer = [UInt8]()
    
    init(content: String, frame: CGRect) {
        super.init(frame: frame) // init function of TerminalView
        terminalDelegate = self
        // Give it the static content
        self.feed(text: "\n") // Give us a row at top for space
        self.feed(text: content)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Needed for conformity to protocol
    public func scrolled(source: TerminalView, position: Double) {
    }
    public func setTerminalTitle(source: TerminalView, title: String) {
    }
    public func sizeChanged(source: TerminalView, newCols: Int, newRows: Int) {
    }
    public func hostCurrentDirectoryUpdate(source: TerminalView, directory: String?) {
    }
    public func send(source: TerminalView, data: ArraySlice<UInt8>) {
    }
}

struct CodeCardTerminal: UIViewControllerRepresentable {
    typealias UIViewControllerType = CodeCardTerminalViewController
    
    @State var content: String // All of the contents to be displayed
    @Binding var width: CGFloat // The width that the terminal should fill
    @Binding var height: CGFloat // The height that the terminal should fill
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<CodeCardTerminal>) -> CodeCardTerminalViewController {
        let viewController = CodeCardTerminalViewController(content: content, width: width, height: height)
        return viewController
    }
    
    // Use to  allow for resizing
    func updateUIViewController(_ uiViewController: CodeCardTerminalViewController, context: UIViewControllerRepresentableContext<CodeCardTerminal>) {
        // Tell the view controller to update its size in case of a resize
        uiViewController.updateDimensions(newWidth: width, newHeight: height)
    }
}
