//
//  ViewController.swift
//  FileView
//
//  Created by Kevin Scardina on 3/21/18.
//  Copyright © 2018 popmedic. All rights reserved.
//

import UIKit

class ConnectViewController: ViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var connectButton: UIButton!
    @IBOutlet weak var ipTextView: UITextField!
    @IBOutlet weak var hostHistoryTableView: UITableView!
    @IBOutlet weak var bottomContraint: NSLayoutConstraint!
    
    static let ACCESS_SEGUE = "ConnectAccessSegue"
    static let DIR_SEGUE = "ConnectDirSegue"
    
    private let connectLogic = ConnectLogicFactory.connectLogic
    private var isRequesting:Bool {
        get {
            return !connectButton.isEnabled
        }
        set(value) {
            UIApplication.shared.isNetworkActivityIndicatorVisible = value
            self.connectButton.isEnabled = !value
            self.ipTextView.isEnabled = !value
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hostHistoryTableView.delegate = self
        self.hostHistoryTableView.dataSource = self
        self.ipTextView.text = connectLogic.host
        
        self.connectButton.setBackgroundColor(UIColor.lightGray, for: .disabled)
        self.useBottomConstraint = bottomContraint
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dirViewController = segue.destination as? DirViewController {
            if let cc = sender as? [String] {
                for c in cc {
                    dirViewController.contents.append(
                        contentsOf:[DirViewController.Node(
                            path:c,
                            expanded:false,
                            children:[DirViewController.Node]()
                        )]
                    )
                }
            }
        }
    }

    @IBAction func connectButtonAction(_ sender: Any) {
        self.isRequesting = true
        connectLogic.connect(ipTextView.text) { (data, err) in
            self.isRequesting = false
            self.hostHistoryTableView.reloadData()
            let r = self.connectLogic.isConnectError(err)
            if r.yes {
                if r.code == 401 || r.code == 403 {
                    self.gotoAccessViewController()
                    return
                }
                self.showAlertOK(title: r.title, message: r.msg, onComplete: nil, onOk: nil)
                return
            }
            var content = [String]()
            do {
                content = try JSONDecoder().decode([String].self, from: data?.body ?? Data())
            } catch let e {
                self.showAlertOK(title: "JSON Decode error", message: e.localizedDescription, onComplete: nil, onOk: nil)
                return
            }
            self.gotoDirViewController(content)
        }
    }
        
    func gotoAccessViewController() {
        self.performSegue(withIdentifier: ConnectViewController.ACCESS_SEGUE, sender: self)
    }
    
    func gotoDirViewController(_ content: [String]) {
        self.performSegue(withIdentifier: ConnectViewController.DIR_SEGUE, sender: content)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return connectLogic.hostHistory.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: HostsTableViewCell.CELL_ID, for: indexPath)
        if let cell = cell as? HostsTableViewCell {
            cell.label.text = connectLogic.getHostFromHistory(indexPath.row)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.ipTextView.text = connectLogic.getHostFromHistory(indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        switch (editingStyle){
        case .delete:
            if self.connectLogic.removeFromHistory(indexPath.row) {
                self.hostHistoryTableView.deleteRows(at: [indexPath], with: .left)
            }
        case .none:
            return
        case .insert:
            return
        }
    }
    
    @IBAction func unwindAction(unwindSegue: UIStoryboardSegue) {}
}

