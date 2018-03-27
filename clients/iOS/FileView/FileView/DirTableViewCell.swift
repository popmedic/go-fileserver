//
//  DirTableViewCell.swift
//  FileView
//
//  Created by Kevin Scardina on 3/23/18.
//  Copyright © 2018 popmedic. All rights reserved.
//

import UIKit

class DirTableViewCell: UITableViewCell {
    static let CELL_ID = "DirTableViewCell"
    
    @IBOutlet weak var indicator: UIActivityIndicatorView!
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let x = CGFloat(self.indentationLevel) * self.indentationWidth
        self.contentView.frame = CGRect(
            x: x,
            y: self.contentView.frame.origin.y,
            width: self.contentView.frame.size.width - x,
            height: self.contentView.frame.size.height
        )
    }

}
