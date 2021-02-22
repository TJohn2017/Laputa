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
    weak var delegate: SwiftUITerminalDelegate?
    var showAddCanvasButton: Bool
    
    init(host: HostInfo, showAddCanvasButton: Bool) {
        self.host = host
        self.showAddCanvasButton = showAddCanvasButton
        self.keyboardButton = UIButton(type: .custom)
        self.addPairButton = UIButton(type: .custom)
        super.init(nibName:nil, bundle:nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Makes the terminal gui frame
    func makeFrame (keyboardDelta: CGFloat) -> CGRect
    {
        var frame_height = view.frame.height
        if (orig_view_height != 0) {
            frame_height = orig_view_height
        }
        print ("frame height: \(frame_height), keyboard delta: \(keyboardDelta)")
        print ("Making frame with \(keyboardDelta)")
        return CGRect (
            x: view.safeAreaInsets.left,
            y: view.safeAreaInsets.top,
            width: view.frame.width - view.safeAreaInsets.left - view.safeAreaInsets.right,
            height: frame_height - view.safeAreaInsets.bottom - view.safeAreaInsets.top - keyboardDelta - 40)
    }
    
    
    // Starts an instance of sshterminalview and writes the first line
    func startSSHSession() -> SSHTerminalView? {
        let tv = SSHTerminalView(host: host, frame: makeFrame(keyboardDelta: 0))
        //tv.feed(text: "Welcome to iPad Terminal\n\n")
        return tv
    }
    
    func addKeyboard() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver (self,
                    selector: #selector(keyboardNotification(_:)),
                    name: UIResponder.keyboardWillShowNotification,
                    object: nil)
        
        notificationCenter.addObserver(self,
                            selector: #selector(keyboardNotification(_:)),
                            name: UIResponder.keyboardWillHideNotification,
                            object: nil)
        
    }
    var keyboardDelta: CGFloat = 0
    @objc
    func keyboardNotification(_ notification: NSNotification) {
        print ("Keyboard showed")
        print("showed: view height: \(view.frame.height)   view width: \(view.frame.width)")
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            //let endFrameY = endFrame?.origin.y ?? 0
            let duration:TimeInterval = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
            let animationCurve:UIView.AnimationOptions = UIView.AnimationOptions(rawValue: animationCurveRaw)
            let relative = view.convert(endFrame ?? CGRect.zero, from: view.window)
            
            let inter = relative.intersection(terminalView!.frame)
            if inter.height > 0 {
                keyboardDelta = inter.height
            }
           // print ("KEYBOARD NOTIFICATION: Forcing frame to \(makeFrame(keyboardDelta: inter.height)) with incoming \(view.frame)")
            
            terminalView!.frame = makeFrame(keyboardDelta: inter.height)
            UIView.animate(withDuration: duration,
                                       delay: TimeInterval(0),
                                       options: animationCurve,
                                       animations: {

                                        self.view.layoutIfNeeded() },
                                       completion: nil)
        }
    }
    
    var orig_view_height:CGFloat = 0
    //var terminalScrollView = UIScrollView()
    // Loads terminal gui into the view
    override func viewDidLoad() {
        super.viewDidLoad()
        addKeyboard()
        orig_view_height = view.frame.height
        
        // start ssh session and add it ot the view
        terminalView = startSSHSession()
        guard let t = terminalView else {
            return
        }
        self.terminalView = t
       
        t.frame = view.frame
        view.addSubview(t)
        
        // initiate addPair button
        if (showAddCanvasButton) {
            initializeAddPairButton(t: t)
            view.addSubview(addPairButton)
        }
        
        // initiate keyboard button
        initializeKeyboardButton(t: t)
        view.addSubview(keyboardButton)
        self.terminalView?.becomeFirstResponder()
        
    }
    
    
    /*override func viewWillAppear(_ animated: Bool) {
        CGFloat fixedWidth = terminalView?.frame.width
        
    }*/
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
    @Binding var showAddCanvasButton: Bool
    typealias UIViewControllerType = SSHTerminalViewController
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<SwiftUITerminal>) -> SSHTerminalViewController {
        let viewController = SSHTerminalViewController (host: host, showAddCanvasButton: showAddCanvasButton)
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
        @State var showAddCanvasButton = true
        var body: some View {
            let host = HostInfo(alias:"Laputa", hostname:"159.65.78.184", username:"laputa", usePassword:true, password:"LaputaIsAwesome")

            return SwiftUITerminal(host: host, showCanvasSheet: $showCanvasSheet, showAddCanvasButton: $showAddCanvasButton)
        }
    }
}
