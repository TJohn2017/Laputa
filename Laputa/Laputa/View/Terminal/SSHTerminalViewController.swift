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
    
    // Variables for catching last output to save it to a code card in an accompanying canvas
    var outputCatchButton: UIButton
    var isCatchingOutput: Bool = false
    var initialDragPoint: CGPoint? = nil
    
    var connected: Bool
    var errorView: UIView
    
    // UI Canvas associated with this terminal. We can send our recent output to the canvas.
    var canvas: Canvas?
    var viewContext: NSManagedObjectContext?
    
    init(connection: SSHConnection?, modifyTerminalHeight: Bool, canvas: Canvas? = nil, viewContext: NSManagedObjectContext? = nil) {
        self.connection = connection
        self.keyboardButton = UIButton(type: .custom)
        self.outputCatchButton = UIButton(type: .custom)
        self.modifyTerminalHeight = modifyTerminalHeight
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
        if (self.modifyTerminalHeight && keyboardDelta > 0) { // set height when keyboard shows up to fill the screen til the keyboard
            view_height += keyboardDelta*0.5 // TODO makes screen start too low
        } else if (keyboardWillHide && previous_height != nil) { // set height to be the previous terminal view height before the keyboard appeared
            view_height = previous_height! - view.safeAreaInsets.bottom - view.safeAreaInsets.top - 30 // WEIRD OFFSET
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
    
    
    // Starts an instance of sshterminalview and writes the first line
    func startSSHSession() -> (SSHTerminalView?, Bool) {
        let tv = SSHTerminalView(connection: connection, frame: makeFrame(keyboardDelta: 0, keyboardWillHide: false))
        return (tv, tv.isConnected())
    }
    
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
    
    @objc func handleKeyboardWillHide() {
        keyboardDelta = 0
        if (terminalView != nil) {
            terminalView!.frame = makeFrame(keyboardDelta: 0, keyboardWillHide: true)
        }
    }
    
    var keyboardDelta: CGFloat = 0
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
                terminalView!.frame = makeFrame(keyboardDelta: keyboardDelta, keyboardWillHide: false)
                UIView.animate(withDuration: duration,
                                           delay: TimeInterval(0),
                                           options: animationCurve,
                                           animations: {

                                            self.view.layoutIfNeeded() },
                                           completion: nil)
            }
        }
    }
    
    override func loadView() {
        print("LOG: loadView called")
        super.loadView()
        if (self.modifyTerminalHeight) {
            previous_height = self.view.bounds.height * 0.49
            self.view.frame = CGRect(
                x: self.view.bounds.origin.x,
                y: self.view.bounds.origin.y,
                width: self.view.bounds.width,
                height: self.view.bounds.height * 0.49
            )
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        var screenMultiplier : CGFloat = 1
        if (modifyTerminalHeight) {
            screenMultiplier = 0.5
        }
        previous_height = size.height * screenMultiplier
        coordinator.animate(alongsideTransition: { (_) in
            self.view.frame = CGRect(
                x: self.view.bounds.origin.x,
                y: self.view.bounds.origin.y,
                width: size.width,
                height: size.height * screenMultiplier - 30 // WEIRD OFFSET
            )
     
            if (self.connected) {
                // reset terminal view frame
                self.terminalView!.frame = self.view.frame
                // reset buttons in terminal view
                self.keyboardButton.frame = CGRect(x: self.view.frame.width - 100, y: self.view.frame.height - 120, width: self.view.frame.width/15, height: self.view.frame.width/15)
                if (self.modifyTerminalHeight) {
                    self.outputCatchButton.frame = CGRect(x: self.view.frame.width - 100, y: self.view.frame.height - 220, width: self.view.frame.width/15, height: self.view.frame.width/15)
                }
            } else {
                self.errorView.center = CGPoint(x: self.view.frame.size.width / 2, y: self.view.frame.size.height / 2)
            }     
        }, completion: nil)
    }
    
    // Loads terminal gui into the view
    override func viewDidLoad() {
        super.viewDidLoad()
        addKeyboard()
        
        previous_height = view.frame.height
        
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
            
            // Initialize Swipe Gesture Recognizer -- for catching output and saving on canvas
            let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(didPan(_:)))
            t.addGestureRecognizer(panGestureRecognizer)
        } else {
            self.errorView.center = CGPoint(x: view.frame.size.width / 2, y: view.frame.size.height / 2)
            view.addSubview(self.errorView)
        }
    }
    
    // Setup the ketboard button UI and behavior
    private func initializeKeyboardButton(t: TerminalView) {
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
    
    // Setup the output catch button UI and behavior
    private func initializeOutputCatchButton(t: TerminalView) {
        outputCatchButton.frame = CGRect(x: t.frame.width - 100, y: t.frame.height - 220, width: t.frame.width/15, height: t.frame.width/15)
        outputCatchButton.layer.cornerRadius = 15
        outputCatchButton.layer.masksToBounds = true
        outputCatchButton.setImage(UIImage(systemName: "arrow.triangle.branch"), for: .normal)
        outputCatchButton.backgroundColor = UIColor.white
        outputCatchButton.addTarget(self, action: #selector(toggleOutputCatching), for: .touchUpInside)
    }
    
    // Toggle output catching mode: when on we will be watching for drag gestures
    // so that a user can save content from the terminal to a code card on a canvas.
    @objc
    func toggleOutputCatching() {
        self.initialDragPoint = nil
        self.isCatchingOutput = !self.isCatchingOutput
    }
    
    // TODO TJ comment
    func saveSelectedOutput() {
        let lastResponse = terminalView?.lastResponse()
        
        if (lastResponse != nil && canvas != nil && viewContext != nil) {
            let newCard = CodeCard(context: viewContext!)
            newCard.id = UUID()
            newCard.origin = canvas

            var maxZIndex = 0.0
            let cards = canvas!.cardArray
            if !cards.isEmpty {
                maxZIndex = cards[0].zIndex + 1.0
            }
            newCard.zIndex = maxZIndex
            newCard.text = lastResponse
        
            do {
                try viewContext!.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    // Handles the pan gesture. Only used when we are in output catching mode to capture
    // the rows from the terminal that the user crossed in their pan gesture and save
    // their content to a new code card on the current canvas.
    @objc
    private func didPan(_ sender: UIPanGestureRecognizer) {
        // If we aren't in output catching mode we don't need to do anything
        if (!isCatchingOutput) {
            return
        }
        
        switch sender.state {
        case .began:
            initialDragPoint = sender.location(in: view)
        case .ended,
             .cancelled:
            // Something went wrong, we need a starting point
            if (initialDragPoint == nil) {
                return
            }

            // Use gesture data to calculate which rows were selected
            let translation = sender.translation(in: view)
            let terminal = terminalView!.getTerminal()
            let (_, rows) = terminal.getDims()
            let viewHeight = view.frame.height - view.safeAreaInsets.bottom - view.safeAreaInsets.top - keyboardDelta
            let rowHeightInPixels = viewHeight / CGFloat(rows)
            var startRowIndex = Int((initialDragPoint!.y / rowHeightInPixels).rounded(.down))
            var endRowIndex = Int(((initialDragPoint!.y + translation.y) / rowHeightInPixels).rounded(.down))
            if (startRowIndex > endRowIndex) { // We need start row index to be the lesser value for our range
                swap(&startRowIndex, &endRowIndex)
            }
            
            // Get content from row data
            var content = ""
            print("TYLER: getting lines from \(startRowIndex) to \(endRowIndex)")
            for i in startRowIndex...endRowIndex { // Loop over each row and concatenate it
                let row = terminal.getLine(row: i)
                if (row != nil) {
                    print("TYLER: appending line \(i)")
                    content += row!.translateToString()
                    if (i != endRowIndex) {
                        content += "\n" // We need to manually append a new line character
                    }
                }
            }
            print("TYLER: \(content)")
        default:
            break
        }
    }
    
    func generateErrorView() -> UIView {
        let errorView = UIView()
        errorView.backgroundColor = .black
        errorView.frame = CGRect(x: 0, y:0, width: 700, height: 700)
        
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
    
    typealias UIViewControllerType = SSHTerminalViewController
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<SwiftUITerminal>) -> SSHTerminalViewController {
        let viewController = SSHTerminalViewController (connection: connection, modifyTerminalHeight: modifyTerminalHeight, canvas: canvas, viewContext: viewContext)
        return viewController
    }
    
    // Need for conformity
    func updateUIViewController(_ uiViewController: SSHTerminalViewController, context: UIViewControllerRepresentableContext<SwiftUITerminal>) {}
    
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

struct SwiftUITerminal_Preview: PreviewProvider {
    static var previews: some View {
        PreviewWrapper()
    }
    
    struct PreviewWrapper: View {
        @State var canvas: Canvas? = nil
        @State var session: SSHConnection? = nil
        
        var body: some View {
            // Establish laputa test connection
            let host = HostInfo(
                alias:"Laputa",
                username:"laputa",
                hostname:"159.65.78.184",
                authType:AuthenticationType.password,
                password:"LaputaIsAwesome",
                publicKey: "",
                privateKey: "",
                privateKeyPassword: ""
            )
            session = SSHConnection(host: host.hostname, andUsername: host.username)
            do {
                try session?.connect(hostInfo: host)
            } catch SSHSessionError.authorizationFailed {
                // TODO TJ how should we show these errors to users?
                let error = SSHSessionError.authorizationFailed
                print("[SSHSessionError] \(error)")
            } catch {
                print("[SSHSessionError] \(error)")
            }

            return SwiftUITerminal(canvas: $canvas, connection: $session, modifyTerminalHeight: false)
        }
    }
}
