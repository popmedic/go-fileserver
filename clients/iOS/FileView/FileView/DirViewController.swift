//
//  DirViewController.swift
//  FileView
//
//  Created by Kevin Scardina on 3/23/18.
//  Copyright © 2018 popmedic. All rights reserved.
//

import UIKit

class DirViewController: ViewController, UITableViewDelegate, UITableViewDataSource {
    private static let BUTTON_HEIGHT:CGFloat = 60.0
    private let DIR_TO_ADMIN_SEGUE = "DirToAdminSegue"
    private let DIR_TO_VIEWER_SEGUE = "DirToViewerSegue"
    
    class Node {
        var title:String {
            get {
                return self.path.lastPathComponent.removingPercentEncoding ?? self.path.lastPathComponent
            }
        }
        var path:String
        var expanded:Bool
        var children:[Node]
        init(path:String, expanded:Bool, children:[Node]) {
            self.path = path
            self.expanded = expanded
            self.children = children
        }
    }
    
    var contents = [Node]()
    var isActive:Bool {
        get {
            return self.tableView.allowsSelection
        }
        set(value) {
            self.tableView.allowsSelection = !value
            self.tableView.isScrollEnabled = !value
            self.exitButton.isEnabled = !value
            self.adminButton.isEnabled = !value
            UIApplication.shared.isNetworkActivityIndicatorVisible = value
        }
    }
    
    @IBOutlet weak var adminButtonHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var adminButton: UIButton!
    @IBOutlet weak var exitButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.showAdminButton(false)
        self.tableView.dataSource = self
        self.tableView.delegate = self
        ConnectLogicFactory.connectLogic.isAdmin { (yes) in
            if yes {
                self.showAdminButton(true, animated:true)
            }
        }
        self.adminButton.setBackgroundColor(UIColor.lightGray, for: .disabled)
        self.exitButton.setBackgroundColor(UIColor.lightGray, for: .disabled)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let adminViewController = segue.destination as? AdminViewController {
            let data = sender as? Data ?? Data()
            do {
                adminViewController.contents = try JSONDecoder().decode(HashMap.self, from: data)
            } catch {
                print("json error: \(String.init(data: data, encoding: .utf8) ?? "no data")")
            }
        } else if let viewerViewController = segue.destination as? ViewerViewController {
            if let tuplet = sender as? (data: Data?, type: String?) {
                let data = tuplet.data ?? Data()
                let type = tuplet.type ?? "application/octet-stream"
                viewerViewController.contents = data
                viewerViewController.contentsType = type
            }
        }
    }
    
    @IBAction func adminButtonAction(_ sender: Any) {
        self.isActive = true
        AuthAPI.authGet { (data, err) in
            self.isActive = false
            let resp = ConnectLogicFactory.connectLogic.isConnectError(err)
            if resp.yes {
                self.showAlertOK(title: resp.title, message: resp.msg, onComplete: nil, onOk: nil)
            } else {
                self.performSegue(withIdentifier: self.DIR_TO_ADMIN_SEGUE, sender: data)
            }
        }
    }
    
    func showAdminButton(_ yes: Bool, animated: Bool = false) {
        func _showAdminButton(_ yes:Bool) {
            adminButton.isHidden = !yes
            if yes {
                adminButtonHeightConstraint.constant = DirViewController.BUTTON_HEIGHT
            } else {
                adminButtonHeightConstraint.constant = 0
            }
            
        }
        if animated {
            UIView.animate(withDuration: 0.25) {
                _showAdminButton(yes)
            }
            return
        }
        _showAdminButton(yes)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countNodes(self.contents)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? DirTableViewCell {
            var i = 0, indent = 0
            if let node = nodeAt(row: indexPath.row, nodes: self.contents, idx: &i, indent: &indent) {
                if !node.expanded {
                    self.isActive = true
                    cell.indicator.startAnimating()
                    PathAPI.pthGet(pth: node.path.deleteFirstSlash(), completion: { (r, err) in
                        self.isActive = false
                        cell.indicator.stopAnimating()
                        let errResp = ConnectLogicFactory.connectLogic.isConnectError(err)
                        if errResp.yes {
                            self.showAlertOK(title: errResp.title, message: errResp.msg, onComplete: nil, onOk: nil)
                            return
                        }
                        if r?.header["Content-Type"] == "application/json" {
                            do {
                                let pp = try JSONDecoder().decode([String].self, from: r?.body ?? Data())
                                var nn = [DirViewController.Node]()
                                var ips = [IndexPath]()
                                var x = 1
                                for p in pp {
                                    nn.append(DirViewController.Node(path: p, expanded: false, children: [DirViewController.Node]()))
                                    ips.append(IndexPath(indexes: [0,indexPath.row+x]))
                                    x += 1
                                }
                                node.children = nn
                                node.expanded = true
                                tableView.insertRows(at: ips, with: UITableViewRowAnimation.bottom)
                            } catch let e {
                                self.showAlertOK(title: "JSON Decode error", message: e.localizedDescription, onComplete: nil, onOk: nil)
                                return
                            }
                        } else {
                            self.performSegue(
                                withIdentifier: self.DIR_TO_VIEWER_SEGUE,
                                sender: (data: r?.body, type: r?.header["Content-Type"])
                            )
                        }
                    })
                } else {
                    var ips = [IndexPath]()
                    for x in 1...node.children.count {
                        ips.append(IndexPath(indexes:[0, indexPath.row+x]))
                    }
                    node.expanded = false
                    tableView.deleteRows(at: ips, with: UITableViewRowAnimation.bottom)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DirTableViewCell.CELL_ID, for: indexPath)
        if let cell = cell as? DirTableViewCell {
            var idx = 0, indent = 0
            cell.label.text = nodeAt(row: indexPath.row, nodes: self.contents, idx: &idx, indent: &indent)?.title ?? ""
            cell.indentationLevel = indent
        }
        return cell
    }
    
    func nodeAt(row:Int, nodes:[Node], idx: inout Int, indent: inout Int) -> Node? {
        for n in nodes {
            if idx == row {
                return n
            }
            idx += 1
            if n.expanded {
                if let nn = nodeAt(row: row, nodes: n.children, idx: &idx, indent: &indent) {
                    indent += 1
                    return nn
                }
            }
        }
        return nil
    }
    
    func countNodes(_ val:[Node]) -> Int {
        var n = 0
        n = val.count
        for k in val {
            if k.expanded {
                n += countNodes(k.children)
            }
        }
        return n
    }

    @IBAction func unwindActionDirViewController(unwindSegue: UIStoryboardSegue) {}
}
