//
//  HostsTableViewCell.swift
//  FileView
//
//  Created by Kevin Scardina on 3/22/18.
//  Copyright © 2018 popmedic. All rights reserved.
//

import UIKit

class HostsTableViewCell: UITableViewCell {
    static let CELL_ID = "HostsTableViewCell"
    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
        if selected {
            UIView.animate(withDuration: 0.1, animations: {
                self.backgroundColor = UIColor.lightGray
            }, completion: { (_) in
                UIView.animate(withDuration: 0.1, animations: {
                    self.backgroundColor = UIColor.clear
                })
            })
        }
    }

}
