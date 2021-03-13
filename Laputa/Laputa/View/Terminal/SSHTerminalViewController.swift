//
//  TerminalViewController.swift
//  Laputa
//
//  Created by Claire Mai on 2/10/21.
//

import Foundation
import SwiftTerm
import SwiftUI
import NMSSH
import CoreData

class SSHTerminalViewController: UIViewController, NMSSHChannelDelegate {
    var connection: SSHConnection?
    var terminalView: SSHTerminalView?
    var keyboardButton: UIButton
    var modifyTerminalHeight: Bool
    var previous_height : CGFloat?
    var splitScreenHeight: CGFloat
    
    // Variables for catching last output to save it to a code card in an accompanying canvas
    var outputCatchButton: UIButton
    var isCatchingOutput: Bool = false
    var initialDragPoint: CGPoint? = nil
    
    var connected: Bool
    var errorView: UIView
    
    // UI Canvas associated with this terminal. We can send our recent output to the canvas.
    var canvas: Canvas?
    var viewContext: NSManagedObjectContext?
    
    init(connection: SSHConnection?, modifyTerminalHeight: Bool, splitScreenHeight: CGFloat, canvas: Canvas? = nil, viewContext: NSManagedObjectContext? = nil) {
        self.connection = connection
        self.keyboardButton = UIButton(type: .custom)
        self.outputCatchButton = UIButton(type: .custom)
        self.modifyTerminalHeight = modifyTerminalHeight
        self.splitScreenHeight = splitScreenHeight
        self.canvas = canvas
        self.connected = false
        self.viewContext = viewContext
        self.errorView = UIView()
        if (canvas != nil) {
            print("CANVAS: We have a canvas")
        }
        super.init(nibName:nil, bundle:nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let navigationBarHeight: CGFloat = 74
    
    // Makes the terminal gui frame
    func makeFrame (keyboardDelta: CGFloat, keyboardWillHide: Bool) -> CGRect
    {
        var view_height = view.frame.height - view.safeAreaInsets.bottom - view.safeAreaInsets.top - keyboardDelta
        print("SSHLOG: make frame view height = \(view_height)")
        if (self.modifyTerminalHeight && keyboardDelta > 0) { // set height when keyboard shows up to fill the screen til the keyboard
//            view_height += keyboardDelta*0.48 - 100 // TODO makes screen start too low
        } else if (keyboardWillHide && previous_height != nil) { // set height to be the previous terminal view height before the keyboard appeared
            view_height = previous_height! - view.safeAreaInsets.bottom - view.safeAreaInsets.top //- navigationBarHeight//30 // WEIRD OFFSET
            print("SSHLOG: make frame, hide keyboard, prev height = \(String(describing: previous_height)), view height = \(view_height)")
        } else if (view_height < 5) { // if view height too small, set minimum height of 50
            view_height = 50
        }
        
        var origin_y = view.safeAreaInsets.top
        if (origin_y > navigationBarHeight) {
            origin_y = navigationBarHeight
        }
        
        return CGRect (
            x: view.safeAreaInsets.left,
            y: origin_y,
            width: view.frame.width - view.safeAreaInsets.left - view.safeAreaInsets.right,
            height: view_height)
    }
    
    func updateTerminalFrame(height: CGFloat) {
//        if (modifyTerminalHeight) {
            view.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: height)
            terminalView!.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: height)
            if (keyboardButton.isHidden) {
                outputCatchButton.frame = CGRect(x: self.view.frame.width - 100, y: self.view.frame.height - 100, width: self.view.frame.width/15, height: self.view.frame.width/15)
            } else {
                keyboardButton.frame = CGRect(x: self.view.frame.width - 100, y: self.view.frame.height - 100, width: self.view.frame.width/15, height: self.view.frame.width/15)
                outputCatchButton.frame = CGRect(x: self.view.frame.width - 100, y: self.view.frame.height - 100 - ((self.view.frame.width/15) * 1.3), width: self.view.frame.width/15, height: self.view.frame.width/15)
            }
            
             
//        }
    }
    
    
    // Starts an instance of sshterminalview and writes the first line
    func startSSHSession() -> (SSHTerminalView?, Bool) {
        let tv = SSHTerminalView(connection: connection, frame: makeFrame(keyboardDelta: 0, keyboardWillHide: false))
        return (tv, tv.isConnected())
    }
    
    // Adds keyboard observers for when the keyboard appears and disappears
    func addKeyboard() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver (self,
                    selector: #selector(keyboardNotification(_:)),
                    name: UIResponder.keyboardWillShowNotification,
                    object: nil)
        
        notificationCenter.addObserver(self,
                            selector: #selector(handleKeyboardWillHide),
                            name: UIResponder.keyboardWillHideNotification,
                            object: nil)
        
    }
    
    var keyboardDelta: CGFloat = 0
    
    // Called when the keyboard is about to hide. Makes a new terminal frame to fill the screen
    @objc func handleKeyboardWillHide() {
        print("SSHLOG: keyboard hide will remake frame, ")
        keyboardDelta = 0
        if (terminalView != nil) {
//            terminalView!.frame = makeFrame(keyboardDelta: 0, keyboardWillHide: true)
            if (self.modifyTerminalHeight) {
                outputCatchButton.frame = CGRect(x: terminalView!.frame.width - 100, y: terminalView!.frame.height - 100 - ((terminalView!.frame.width/15) * 1.3), width: terminalView!.frame.width/15, height: terminalView!.frame.width/15)
            } else {
                terminalView!.frame = makeFrame(keyboardDelta: 0, keyboardWillHide: true)
            }
            keyboardButton.frame = CGRect(x: terminalView!.frame.width - 100, y: terminalView!.frame.height - 100, width: terminalView!.frame.width/15, height: terminalView!.frame.width/15)
        }
        keyboardButton.isHidden = false
    }
    
    // Called when the keyboard is about to appear.
    //Makes a new smaller frame for the terminal to compensate for the keyboard filling the screen.
    @objc
    func keyboardNotification(_ notification: NSNotification) {
        
        if let userInfo = notification.userInfo {
            let keyboardSize = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let duration:TimeInterval = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
            let animationCurve:UIView.AnimationOptions = UIView.AnimationOptions(rawValue: animationCurveRaw)

            if (keyboardSize != nil) {
                keyboardDelta = keyboardSize!.height
            } else {
                keyboardDelta = 0
            }
            if (terminalView != nil) {
                
                if (self.modifyTerminalHeight) { // update catch output button so it's above the keyboard
                    outputCatchButton.frame = CGRect(x: terminalView!.frame.width - 100, y: terminalView!.frame.height - 100, width: terminalView!.frame.width/15, height: terminalView!.frame.width/15)
                } else {
                    terminalView!.frame = makeFrame(keyboardDelta: keyboardDelta, keyboardWillHide: false)
                }
                UIView.animate(withDuration: duration,
                                           delay: TimeInterval(0),
                                           options: animationCurve,
                                           animations: {

                                            self.view.layoutIfNeeded() },
                                           completion: nil)
                keyboardButton.isHidden = true
            }
        }
    }
    
    // Called every time the screen is rotated
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
//        var screenMultiplier : CGFloat = 1
        if (modifyTerminalHeight) {
            previous_height = splitScreenHeight
//            screenMultiplier = 0.5
        } else {
            previous_height = size.height - navigationBarHeight
        }
//        previous_height = size.height * screenMultiplier
        // Reset parent terminal view frame
        coordinator.animate(alongsideTransition: { (_) in
            self.view.frame = CGRect(
                x: self.view.bounds.origin.x,
                y: self.view.bounds.origin.y,
                width: size.width,
                height: self.previous_height! //size.height * screenMultiplier - 30 // WEIRD OFFSET
            )
     
            if (self.connected) {
                // reset terminal view frame
                self.terminalView!.frame = self.view.frame
                // reset buttons in terminal view
                self.keyboardButton.frame = CGRect(x: self.view.frame.width - 100, y: self.view.frame.height - 100, width: self.view.frame.width/15, height: self.view.frame.width/15)
                if (self.modifyTerminalHeight) { // TODO change button origins to match (i.e. either use self.view.frame or self.terminalView!.frame
                    self.outputCatchButton.frame = CGRect(x: self.terminalView!.frame.width - 100, y: self.terminalView!.frame.height - 100 - ((self.terminalView!.frame.width/15) * 1.3), width: self.terminalView!.frame.width/15, height: self.terminalView!.frame.width/15)
                }
            } else {
                self.errorView.center = CGPoint(x: self.view.frame.size.width / 2, y: self.view.frame.size.height / 2)
            }     
        }, completion: nil)
    }
    
    // Called once when the view is first loaded
    override func loadView() {
        print("SSHLOG: loadView called, with split screen height: \(splitScreenHeight)")
        super.loadView()
        if (self.modifyTerminalHeight) {
            previous_height = splitScreenHeight //self.view.bounds.height * 0.49
            self.view.frame = CGRect(
                x: self.view.bounds.origin.x,
                y: self.view.bounds.origin.y,
                width: self.view.bounds.width,
                height: splitScreenHeight //self.view.bounds.height * 0.49
            )
        } else {
            previous_height = view.frame.height - navigationBarHeight
        }
    }
    
    // Called once after the view is first loaded
    // Loads terminal gui into the view
    override func viewDidLoad() {
        super.viewDidLoad()
        addKeyboard()
        
//        previous_height = view.frame.height
        
        // start ssh session and add it ot the view
        let (terminalView, connected) = startSSHSession()
        self.connected = connected
        
        // Initialize default-failure page (in case of no connection).
        self.errorView = self.generateErrorView()
        
        // Otherwise, display the terminal view.
        if (self.connected) {
            guard let t = terminalView else {
                return
            }
            self.terminalView = t
            t.frame = view.frame
            view.addSubview(t)
            
            // We have a canvas, so show the output catching button
            if (self.modifyTerminalHeight) {
                initializeOutputCatchButton(t: t)
                view.addSubview(outputCatchButton)
            }
            
            // initiate keyboard button
            initializeKeyboardButton(t: t)
            view.addSubview(keyboardButton)
            self.terminalView?.becomeFirstResponder()

            // Initialize Swipe Gesture Recognizer -- for catching output and saving on canvas and for scrolling the terminal
            let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(didPan(_:)))
            t.addGestureRecognizer(panGestureRecognizer)
          
        } else {
            view.addSubview(self.errorView)
        }
    }
    
    // TODO change button origins to match (i.e. either use self.view.frame or self.terminalView!.frame
    // Setup the ketboard button UI and behavior
    private func initializeKeyboardButton(t: TerminalView) {
        print("SSHLOG: initialize keyboard button according to terminal")
        keyboardButton.frame = CGRect(x: t.frame.width - 100, y: t.frame.height - 120, width: t.frame.width/15, height: t.frame.width/15)
        keyboardButton.layer.cornerRadius = 15
        keyboardButton.layer.masksToBounds = true
        keyboardButton.setImage(UIImage(systemName: "keyboard"), for: .normal)
        keyboardButton.backgroundColor = UIColor.white
        keyboardButton.addTarget(self, action: #selector(showKeyboard), for: .touchUpInside)
    }
    
    // Present the keyboard
    @objc
    func showKeyboard() {
        self.terminalView?.becomeFirstResponder()
    }
    
    // TODO change button origins to match (i.e. either use self.view.frame or self.terminalView!.frame
    // Setup the output catch button UI and behavior
    private func initializeOutputCatchButton(t: TerminalView) {
        outputCatchButton.frame = CGRect(x: t.frame.width - 100, y: t.frame.height - 150, width: t.frame.width/15, height: t.frame.width/15)
        outputCatchButton.layer.cornerRadius = 15
        outputCatchButton.layer.masksToBounds = true
        outputCatchButton.setImage(UIImage(systemName: "rectangle.stack.badge.plus"), for: .normal)
        outputCatchButton.backgroundColor = UIColor.white
        outputCatchButton.addTarget(self, action: #selector(toggleOutputCatching), for: .touchUpInside)
    }
    
    // Toggle output catching mode: when on we will be watching for drag gestures
    // so that a user can save content from the terminal to a code card on a canvas.
    @objc
    func toggleOutputCatching() {
        self.initialDragPoint = nil
        self.lastScrollPoint = nil
        self.isCatchingOutput = !self.isCatchingOutput
        if (self.isCatchingOutput) {
            outputCatchButton.backgroundColor = UIColor.gray
        } else {
            outputCatchButton.backgroundColor = UIColor.white
        }
    }
    
    // Given the content from a terminal in string form saves it to a code card on the
    // current if one exists. If no canvas or view context is present does nothing.
    func saveContentToCodeCard(content: String) {
        if (canvas != nil && viewContext != nil) {
            let newCard = CodeCard(context: viewContext!)
            newCard.id = UUID()
            newCard.origin = canvas

            var maxZIndex = 0.0
            let cards = canvas!.cardArray
            if !cards.isEmpty {
                maxZIndex = cards[0].zIndex + 1.0
            }
            newCard.zIndex = maxZIndex
            newCard.text = content
        
            do {
                try viewContext!.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    // Gets the row indices for the start and end rows of the text we're highlighting
    private func getStartEndRowIndex (startPoint: CGPoint, translation: CGPoint, rows: Int) -> (startRowIndex: Int, endRowIndex: Int, rowHeightInPixels: CGFloat) {
        let viewHeight = view.frame.height - view.safeAreaInsets.bottom - view.safeAreaInsets.top - keyboardDelta
        let rowHeightInPixels = viewHeight / CGFloat(rows)
        let startRowIndex = Int((startPoint.y / rowHeightInPixels).rounded(.down))
        let endRowIndex = Int(((startPoint.y + translation.y) / rowHeightInPixels).rounded(.down))
        return (startRowIndex, endRowIndex, rowHeightInPixels)
    }

    // Bollean to determine if we should be scrolling.
    // Allows less sensitivity when pan gesture is recognized so that we only scroll
    // up or down 1 line every other time didPan is called for scrolling.
    var shouldScroll: Bool = false
    var lastScrollPoint : CGPoint?
    var highlightView: UIView?
    // Handles the pan gesture. Used when we are in output catching mode to capture
    // the rows from the terminal that the user crossed in their pan gesture and save
    // their content to a new code card on the current canvas. If not in output catching mode
    // then it's used for scrolling the terminal up and down.
    @objc
    private func didPan(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
        
        case .began:
            initialDragPoint = sender.location(in: view)
            lastScrollPoint = sender.location(in: view)
            
        case .changed:
            // .began failed to get last drag point location from previous tick, i.e. something went wrong!
            if (lastScrollPoint == nil) {
                return
            }
            let terminal = terminalView!.getTerminal()
            let (_, rows) = terminal.getDims()
            
            
            // Scrolling
            if (!isCatchingOutput) {
                var (startRowIndex, endRowIndex, _) = getStartEndRowIndex(startPoint: lastScrollPoint!, translation: sender.translation(in: view), rows: rows)
                startRowIndex = abs(startRowIndex)
                endRowIndex = abs(endRowIndex)
                if (startRowIndex > endRowIndex && shouldScroll){ // scrolling down
                    terminalView?.scrollDown(lines: 1)
                } else if (startRowIndex < endRowIndex && shouldScroll) { // scrolling up
                    terminalView?.scrollUp(lines: 1)
                }
                shouldScroll.toggle()
                lastScrollPoint = sender.location(in: view)
            } else { // capturing output, highlight the rows that are currently selected
                var (startRowIndex, endRowIndex, rowHeightInPixels) = getStartEndRowIndex(startPoint: initialDragPoint!, translation: sender.translation(in: view), rows: rows)
                startRowIndex = abs(startRowIndex)
                endRowIndex = abs(endRowIndex)
                if (startRowIndex > endRowIndex) { // We need start row index to be the lesser value for our range
                    swap(&startRowIndex, &endRowIndex)
                }
                let numRows = abs(endRowIndex - startRowIndex) + 1
                let origin_y = CGFloat(startRowIndex)*rowHeightInPixels
             
                if (highlightView != nil && highlightView!.isDescendant(of: view)) {
                    highlightView!.frame = CGRect(x: view.safeAreaInsets.left, y: origin_y + 4, width: view.frame.width, height: CGFloat(numRows)*rowHeightInPixels)
                } else if (numRows > 0){
                    highlightView = UIView(frame: CGRect(x: view.safeAreaInsets.left, y: origin_y + 4, width: view.frame.width, height: CGFloat(numRows)*rowHeightInPixels))
                    highlightView!.backgroundColor = .white
                    highlightView!.alpha = 0.25
                    view.addSubview(highlightView!)
                }
            }
            
        case .ended,
             .cancelled:
            // Leave if we're not catching output
            if(!isCatchingOutput) {
                return
            }
            
            // Something went wrong, we need a starting point
            if (initialDragPoint == nil) {
                return
            }

            // Use gesture data to calculate which rows were selected
            let terminal = terminalView!.getTerminal()
            let (_, rows) = terminal.getDims()
            var (startRowIndex, endRowIndex, _) = getStartEndRowIndex(startPoint: initialDragPoint!, translation: sender.translation(in: view), rows: rows)
            if (startRowIndex > endRowIndex) { // We need start row index to be the lesser value for our range
                swap(&startRowIndex, &endRowIndex)
            }

            // Get content from row data
            var content = ""
            for i in startRowIndex...endRowIndex { // Loop over each row and concatenate it
                let row = terminal.getLine(row: i)
                if (row != nil) {
                    content += row!.translateToString()
                    if (i != endRowIndex) {
                        content += "\n" // We need to manually append a new line character
                    }
                }
            }
            
            // Save the content to a code card and exit output catching mode
            saveContentToCodeCard(content: content)
            toggleOutputCatching()
        
            // Deletes the rectangle view used to highlight the terminal lines
            if (highlightView != nil) {
                highlightView!.removeFromSuperview()
                highlightView = nil
            }
        default:
            break
        }
    }
    
    func generateErrorView() -> UIView {
        let errorView = UIView()
        errorView.backgroundColor = .black
        errorView.frame = CGRect(x: 0, y:0, width: view.bounds.width, height: view.bounds.height)
        
        // Set error symbol.
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 140, weight: .bold, scale: .large)
        let img = UIImageView(image: UIImage(systemName: "exclamationmark.triangle", withConfiguration: largeConfig))
        img.tintColor = .red
        img.center = CGPoint(
            x: errorView.frame.size.width / 2,
            y: errorView.frame.size.height / 2
        )
        errorView.addSubview(img)
        
        // Set error message.
        let errorLabel = UILabel(frame: CGRect(x: 0, y:0, width: 500, height: 50))
        errorLabel.text = "Unable to connect. Make sure that the host information is correct."
        errorLabel.textColor = .white
        errorLabel.center = CGPoint(
            x: errorView.frame.size.width/2,
            y: errorView.frame.size.height/2 + img.frame.size.height - 65)
        errorView.addSubview(errorLabel)
        
        return errorView
    }
    
}

// SwiftUI Terminal Object
struct SwiftUITerminal: UIViewControllerRepresentable {
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var canvas: Canvas?
    @Binding var connection: SSHConnection?
    @State var modifyTerminalHeight: Bool
    @Binding var splitScreenHeight: CGFloat
    
    typealias UIViewControllerType = SSHTerminalViewController
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<SwiftUITerminal>) -> SSHTerminalViewController {
        let viewController = SSHTerminalViewController (connection: connection, modifyTerminalHeight: modifyTerminalHeight, splitScreenHeight: splitScreenHeight, canvas: canvas, viewContext: viewContext)
        print("SSHLOG: make UI View Controller called, split screen height: \(splitScreenHeight)")
        return viewController
    }
    
    // Need for conformity
    func updateUIViewController(_ uiViewController: SSHTerminalViewController, context: UIViewControllerRepresentableContext<SwiftUITerminal>) {
        if (modifyTerminalHeight) {
            print("SSHLOG: update ui view controller called: split screen height = \(splitScreenHeight)")
            uiViewController.updateTerminalFrame(height: splitScreenHeight)
        }
    }
    
    // Coordinator will be used to share the canvas sheet toggle
    // variable with our parent views
    class Coordinator: NSObject {
        var parent: SwiftUITerminal
        
        init(parent: SwiftUITerminal) {
            self.parent = parent
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    static func dismantleUIViewController(_ uiViewController: SSHTerminalViewController, coordinator: Coordinator) {
//        uiViewController.terminalView?.ssh_session?.disconnect()
    }
}

//struct SwiftUITerminal_Preview: PreviewProvider {
//    static var previews: some View {
//        PreviewWrapper()
//    }
//
//    struct PreviewWrapper: View {
//        @State var canvas: Canvas? = nil
//        @State var session: SSHConnection? = nil
////        @Binding var height:Binding<CGFloat> = 500
//
//        var body: some View {
//            // Establish laputa test connection
//            let host = HostInfo(
//                alias:"Laputa",
//                username:"laputa",
//                hostname:"159.65.78.184",
//                authType:AuthenticationType.password,
//                password:"LaputaIsAwesome",
//                publicKey: "",
//                privateKey: "",
//                privateKeyPassword: ""
//            )
//            session = SSHConnection(host: host.hostname, andUsername: host.username)
//            do {
//                try session?.connect(hostInfo: host)
//            } catch SSHSessionError.authorizationFailed {
//                // TODO TJ how should we show these errors to users?
//                let error = SSHSessionError.authorizationFailed
//                print("[SSHSessionError] \(error)")
//            } catch {
//                print("[SSHSessionError] \(error)")
//            }
//
//            return SwiftUITerminal(canvas: $canvas, connection: $session, modifyTerminalHeight: false, splitScreenHeight: Binding<CGFloat>(500))
//        }
//    }
//}
