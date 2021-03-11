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
    // - How can we handle scrolling in the dummy view? As things are these aren't interactable at all
    
    // Class variables
    var command_buffer = [UInt8]()
    
    init(content: String, frame: CGRect) {
        super.init(frame: frame) // init function of TerminalView
        terminalDelegate = self
        
        // Resize the terminal to take only the amount of space that is required
        self.setOptimalSize(content: content)
        print("content: \(content)")
        // Give it the static content
        self.feed(text: content)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // TODO TJ comment
    private func setOptimalSize(content: String) {
        var numLines = 0 // Determines optimal height
        var longestLineLenth = 0 // Determines optimal width
        var currLineLength = 0 // Track our current line length
        
        // Loop over the entire content string to find spacial attributes
        for char in content {
            if (char == "\n") {
                numLines += 1
            } else {
                currLineLength += 1
                if (currLineLength > longestLineLenth) {
                    longestLineLenth = currLineLength
                }
            }
        }
        
        // Resize to be only the size that we need
        let terminal = self.getTerminal()
        terminal.resize(cols: longestLineLenth, rows: numLines)
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
    
    // Need for conformity
    func updateUIViewController(_ uiViewController: CodeCardTerminalViewController, context: UIViewControllerRepresentableContext<CodeCardTerminal>) {
        // Tell the view controller to update its size in case of a resize
        uiViewController.updateDimensions(newWidth: width, newHeight: height)
    }
}

//struct CodeCardTerminal_Previews: PreviewProvider {
//    @Binding var width : CGFloat
//    @Binding var height : CGFloat
//    static var previews: some View {
//        CodeCardTerminal(content: "PREVIEW", width: $width, height: $height)
//    }
//}
