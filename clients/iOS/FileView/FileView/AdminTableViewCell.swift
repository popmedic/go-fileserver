//
//  AdminTableViewCell.swift
//  FileView
//
//  Created by Kevin Scardina on 3/26/18.
//  Copyright © 2018 popmedic. All rights reserved.
//

import UIKit

protocol AdminTableViewCellDelegate {
    func onAllowButtonAction(_ cell: AdminTableViewCell, sender: Any)
}

class AdminTableViewCell: UITableViewCell {
    static let CELL_ID = "AdminTableViewCell"
    
    public var delegate:AdminTableViewCellDelegate? = nil
    
    @IBOutlet weak var keyLabel: UILabel!
    @IBOutlet weak var claimTextField: UITextField!
    @IBOutlet weak var allowButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        if selected {
            self.backgroundColor = UIColor.init(red: 0.0, green: 0.0, blue: 0.2, alpha: 1.0)
        } else {
            self.backgroundColor = UIColor.clear
        }
    }
    
    @IBAction func allowButtonAction(_ sender: Any) {
        if let d = self.delegate {
            d.onAllowButtonAction(self, sender: sender)
        }
    }
}
