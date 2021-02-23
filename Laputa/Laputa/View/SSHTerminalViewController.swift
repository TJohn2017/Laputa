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

class SSHTerminalViewController: UIViewController, NMSSHChannelDelegate {
    var host: HostInfo
    var terminalView: SSHTerminalView?
    var keyboardButton: UIButton
    var addPairButton: UIButton
    var modifyTerminalHeight: Bool
    weak var delegate: SwiftUITerminalDelegate?
    var previous_height : CGFloat?
    
    init(host: HostInfo, modifyTerminalHeight: Bool) {
        self.host = host
        self.keyboardButton = UIButton(type: .custom)
        self.addPairButton = UIButton(type: .custom)
        self.modifyTerminalHeight = modifyTerminalHeight
        super.init(nibName:nil, bundle:nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Makes the terminal gui frame
    func makeFrame (keyboardDelta: CGFloat, keyboardWillHide: Bool) -> CGRect
    {
//        print ("LOG: frame height: \(view.frame.height), keyboard delta: \(keyboardDelta)")
//        print ("LOG: Making frame height: \(view.frame.height - view.safeAreaInsets.bottom - view.safeAreaInsets.top - keyboardDelta /*- 20*/)   width: \(view.frame.width - view.safeAreaInsets.left - view.safeAreaInsets.right)   x,y : (\(view.safeAreaInsets.left), \(view.safeAreaInsets.top))")
//        print ("LOG: view.safeAreaInsets.bottom: \(view.safeAreaInsets.bottom)   top: \(view.safeAreaInsets.top)")
        
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
    func startSSHSession() -> SSHTerminalView? {
        let tv = SSHTerminalView(host: host, frame: makeFrame(keyboardDelta: 0, keyboardWillHide: false))
        return tv
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
//        print ("Keyboard showed")
//        print("showed: view height: \(view.frame.height)   view width: \(view.frame.width)")
        if let userInfo = notification.userInfo {
            let keyboardSize = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            //let endFrameY = endFrame?.origin.y ?? 0
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
     
            // reset terminal view frame
            self.terminalView!.frame = self.view.frame
            // reset buttons in terminal view
            self.keyboardButton.frame = CGRect(x: self.view.frame.width - 100, y: self.view.frame.height - 120, width: self.view.frame.width/15, height: self.view.frame.width/15)
            self.addPairButton.frame = CGRect(x: self.view.frame.width - 100, y: self.view.frame.height - 220, width: self.view.frame.width / 15, height: self.view.frame.width/15)
        }, completion: nil)

    }
    
    // Loads terminal gui into the view
    override func viewDidLoad() {
        super.viewDidLoad()
        addKeyboard()
        
        previous_height = view.frame.height
        
        // start ssh session and add it ot the view
        terminalView = startSSHSession()
        guard let t = terminalView else {
            return
        }
        self.terminalView = t
       
        t.frame = view.frame
        view.addSubview(t)
        
        // initiate addPair button
        if (!self.modifyTerminalHeight) {
            initializeAddPairButton(t: t)
            view.addSubview(addPairButton)
        }
        
        // initiate keyboard button
        initializeKeyboardButton(t: t)
        view.addSubview(keyboardButton)
    }
    

    private func initializeAddPairButton(t: TerminalView) {
        addPairButton.frame = CGRect(x: t.frame.width - 100, y: t.frame.height - 220, width: t.frame.width / 15, height: t.frame.width/15)
        addPairButton.layer.cornerRadius = 15
        addPairButton.layer.masksToBounds = true
        addPairButton.setImage(UIImage(systemName: "plus"), for: .normal)
        addPairButton.backgroundColor = UIColor.white
        addPairButton.addTarget(self, action: #selector(showCanvasSheet), for: .touchUpInside)
    }
    
    // This function tells the delegate to present the canvas sheet
    @objc
    func showCanvasSheet() {
        self.delegate?.showCanvasSheet(self, showCanvas: true)
    }
    
    private func initializeKeyboardButton(t: TerminalView) {
        keyboardButton.frame = CGRect(x: t.frame.width - 100, y: t.frame.height - 120, width: t.frame.width/15, height: t.frame.width/15)
        keyboardButton.layer.cornerRadius = 15
        keyboardButton.layer.masksToBounds = true
        keyboardButton.setImage(UIImage(systemName: "keyboard"), for: .normal)
        keyboardButton.backgroundColor = UIColor.white
        keyboardButton.addTarget(self, action: #selector(showKeyboard), for: .touchUpInside)
    }
    
    @objc
    func showKeyboard() {
        self.terminalView?.becomeFirstResponder()
    }
}

// SwiftUI Terminal Object
struct SwiftUITerminal: UIViewControllerRepresentable {
    @State var host: HostInfo
    @Binding var showCanvasSheet: Bool
    @State var modifyTerminalHeight: Bool
    typealias UIViewControllerType = SSHTerminalViewController
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<SwiftUITerminal>) -> SSHTerminalViewController {
        let viewController = SSHTerminalViewController (host: host, modifyTerminalHeight: modifyTerminalHeight)
        viewController.delegate = context.coordinator
        return viewController
    }
    
    // Need for conformity
    func updateUIViewController(_ uiViewController: SSHTerminalViewController, context: UIViewControllerRepresentableContext<SwiftUITerminal>) {}
    
    // Coordinator will be used to share the canvas sheet toggle
    // variable with our parent views
    class Coordinator: NSObject, SwiftUITerminalDelegate {
        var parent: SwiftUITerminal
        let showCanvasSheetBinding: Binding<Bool>
        
        init(parent: SwiftUITerminal, showCanvasSheetBinding: Binding<Bool>) {
            self.showCanvasSheetBinding = showCanvasSheetBinding
            self.parent = parent
        }
        
        // This function allows us to propagate a toggled value through our view controller back to our parent
        func showCanvasSheet(_ viewController: SSHTerminalViewController, showCanvas: Bool) {
            showCanvasSheetBinding.wrappedValue = showCanvas
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self, showCanvasSheetBinding: $showCanvasSheet)
    }
}

protocol SwiftUITerminalDelegate: AnyObject {
    func showCanvasSheet(_ viewController: SSHTerminalViewController, showCanvas: Bool)
}

struct SwiftUITerminal_Preview: PreviewProvider {
    static var previews: some View {
        PreviewWrapper()
    }
    
    struct PreviewWrapper: View {
        @State var showCanvasSheet = false
        
        var body: some View {
            let host = HostInfo(alias:"Laputa", hostname:"159.65.78.184", username:"laputa", usePassword:true, password:"LaputaIsAwesome")

            return SwiftUITerminal(host: host, showCanvasSheet: $showCanvasSheet, modifyTerminalHeight: false)
        }
    }
}
