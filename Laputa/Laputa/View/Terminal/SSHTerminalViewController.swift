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
    var host: HostInfo
    var terminalView: SSHTerminalView?
    var keyboardButton: UIButton
    var outputCatchButton: UIButton
    var modifyTerminalHeight: Bool
    var previous_height : CGFloat?
    
    var connected: Bool
    var errorView: UIView
    
    // UI Canvas associated with this terminal. We can send our recent output to the canvas.
    var canvas: Canvas?
    var viewContext: NSManagedObjectContext?
    
    init(host: HostInfo, modifyTerminalHeight: Bool, canvas: Canvas? = nil, viewContext: NSManagedObjectContext? = nil) {
        self.host = host
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
    
    // Makes the terminal gui frame
    func makeFrame (keyboardDelta: CGFloat, keyboardWillHide: Bool) -> CGRect
    {
        var view_height = view.frame.height - view.safeAreaInsets.bottom - view.safeAreaInsets.top - keyboardDelta
        if (self.modifyTerminalHeight && keyboardDelta > 0) { // set height when keyboard shows up to fill the screen til the keyboard
            view_height += keyboardDelta*0.53
        } else if (keyboardWillHide && previous_height != nil) { // set height to be the previous terminal view height before the keyboard appeared
            view_height = previous_height! - view.safeAreaInsets.bottom - view.safeAreaInsets.top - 30
        } else if (view_height < 5) { // if view height too small, set minimum height of 50
            view_height = 50
        }
        
        return CGRect (
            x: view.safeAreaInsets.left,
            y: view.safeAreaInsets.top,
            width: view.frame.width - view.safeAreaInsets.left - view.safeAreaInsets.right,
            height: view_height)
    }
    
    
    // Starts an instance of sshterminalview and writes the first line
    func startSSHSession() -> (SSHTerminalView?, Bool) {
        let tv = SSHTerminalView(host: host, frame: makeFrame(keyboardDelta: 0, keyboardWillHide: false))
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
        terminalView!.frame = makeFrame(keyboardDelta: 0, keyboardWillHide: true)
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
            
            terminalView!.frame = makeFrame(keyboardDelta: keyboardDelta, keyboardWillHide: false)
            UIView.animate(withDuration: duration,
                                       delay: TimeInterval(0),
                                       options: animationCurve,
                                       animations: {

                                        self.view.layoutIfNeeded() },
                                       completion: nil)
        }
    }
    
    override func loadView() {
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
                height: size.height * screenMultiplier - 30
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
        outputCatchButton.addTarget(self, action: #selector(catchOutput), for: .touchUpInside)
    }
    
    // Attempt to execute the current command prompt and catch the output
    // so that it can be displayed in its own canvas card instead of in the
    // terminal view.
    @objc
    func catchOutput() {
        let lastResponse = terminalView?.lastResponse()
        
        // TODO TJ: remove this and replace it with real code once last response tracking works. For now, just using dummy data.
        if (lastResponse != nil && canvas != nil && viewContext != nil) {
            print("We are attempting to create a card")
            let newCard = CodeCard(context: viewContext!)
            newCard.id = UUID()
            newCard.origin = canvas

            var maxZIndex = 0.0
            let cards = canvas!.cardArray
            if !cards.isEmpty {
                maxZIndex = cards[0].zIndex + 1.0
            }
            newCard.zIndex = maxZIndex
            newCard.text = "last response:\(lastResponse!) \(newCard.id)\n\nx: \(newCard.locX), y: \(newCard.locY)"

            do {
                try viewContext!.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
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
    @State var host: HostInfo
    @Binding var canvas: Canvas?
    @State var modifyTerminalHeight: Bool
    
    typealias UIViewControllerType = SSHTerminalViewController
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<SwiftUITerminal>) -> SSHTerminalViewController {
        let viewController = SSHTerminalViewController (host: host, modifyTerminalHeight: modifyTerminalHeight, canvas: canvas, viewContext: viewContext)
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
        uiViewController.terminalView?.ssh_session.disconnect()
    }
}

struct SwiftUITerminal_Preview: PreviewProvider {
    static var previews: some View {
        PreviewWrapper()
    }
    
    struct PreviewWrapper: View {
        @State var canvas: Canvas? = nil
        
        var body: some View {
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

            return SwiftUITerminal(host: host, canvas: $canvas, modifyTerminalHeight: false)
        }
    }
}
