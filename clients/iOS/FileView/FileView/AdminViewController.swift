//
//  AdminViewController.swift
//  FileView
//
//  Created by Kevin Scardina on 3/24/18.
//  Copyright © 2018 popmedic. All rights reserved.
//

import UIKit

class AdminViewController: ViewController, UITableViewDelegate, UITableViewDataSource, AdminTableViewCellDelegate {
    var contents:HashMap = HashMap()
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.useBottomConstraint = bottomConstraint
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contents.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AdminTableViewCell.CELL_ID, for: indexPath)
        if let cell = cell as? AdminTableViewCell {
            cell.delegate = self
            cell.keyLabel.text = contents[indexPath.row].key
        }
        return cell
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 118.0
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
    
    func onAllowButtonAction(_ cell: AdminTableViewCell, sender: Any) {
        if cell.claimTextField.text?.count ?? 0 > 0 {
            AuthAPI.authPut(
                key: HashSet.init(key: cell.keyLabel.text ?? "unknown", value: cell.claimTextField.text!),
                completion:{ (_, err) in
                let resp = ConnectLogicFactory.connectLogic.isConnectError(err)
                if resp.yes {
                    self.showAlertOK(title: resp.title, message: resp.msg, onComplete: nil, onOk: nil)
                } else {
                    if let ip = self.tableView.indexPath(for: cell) {
                        self.contents.remove(at: ip.row)
                        self.tableView.deleteRows(at: [ip], with: .left)
                    }
                }
            })
        } else {
            self.showAlertOK(title: "Claim", message: "Claim must be filled out.", onComplete: nil, onOk: nil)
        }
    }

}
