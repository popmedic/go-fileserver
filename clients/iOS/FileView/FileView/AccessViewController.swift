//
//  AccessViewController.swift
//  FileView
//
//  Created by Kevin Scardina on 3/21/18.
//  Copyright © 2018 popmedic. All rights reserved.
//

import UIKit

class AccessViewController: ViewController {
    @IBOutlet weak var requestAccessButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    
    private var isRequesting:Bool {
        get {
            return !self.requestAccessButton.isEnabled
        }
        set(value) {
            UIApplication.shared.isNetworkActivityIndicatorVisible = value
            self.requestAccessButton.isEnabled = !value
            self.doneButton.isEnabled = !value
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.doneButton.setBackgroundColor(UIColor.lightGray, for: .disabled)
        self.requestAccessButton.setTitleColor(UIColor.darkGray, for: .disabled)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func requestAccessButtonAction(_ sender: Any) {
        self.isRequesting = true
        AuthAPI.authPost(key: Key(key:ConnectLogicFactory.connectLogic.key)) { (err) in
            self.isRequesting = false
            if let err = err {
                switch err {
                case let err as ErrorResponse:
                    switch(err) {
                    case .error(let c, let d, let e):
                        switch(c) {
                        default:
                            self.showAlertOK(
                                title:"Error \(c)",
                                message:self.getErrorResponseMessage(e, data: d),
                                onComplete: nil,
                                onOk:nil
                            )
                            return
                        }
                    }
                default:
                    self.showAlertOK(
                            title: "ERROR",
                            message: err.localizedDescription,
                            onComplete: nil,
                            onOk: nil
                    )
                    return
                }
            }
            self.showAlertOK(
                title: "Awaiting access",
                message: "Please check back later, a administrator will or will not grant you access. BTW: your key is \(ConnectLogicFactory.connectLogic.key)",
                onComplete: nil,
                onOk: nil
            )
        }
    }
        
    func getErrorResponseMessage(_ err:Error, data:Data?) -> String {
        var msg:String
        do {
            let msgObj = try JSONDecoder().decode(Error500.self, from: data ?? Data())
            msg = msgObj.error ?? err.localizedDescription
        } catch {
            msg = err.localizedDescription
        }
        return msg
    }
    
    func generateKey() -> String {
        return String.random()
    }
        
}
