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
//    var contentString: String
    
    init(content: String, frame: CGRect) {
//        self.contentString = content
        super.init(frame: frame) // init function of TerminalView
        terminalDelegate = self
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
    
    @State var content: String
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<CodeCardTerminal>) -> CodeCardTerminalViewController {
        let viewController = CodeCardTerminalViewController(content: content)
        return viewController
    }
    
    // Need for conformity
    func updateUIViewController(_ uiViewController: CodeCardTerminalViewController, context: UIViewControllerRepresentableContext<CodeCardTerminal>) {}
}

struct CodeCardTerminal_Previews: PreviewProvider {
    static var previews: some View {
        CodeCardTerminal(content: "PREVIEW")
    }
}
