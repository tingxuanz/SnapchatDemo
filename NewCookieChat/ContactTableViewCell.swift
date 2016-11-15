//
//  ContactTableViewCell.swift
//  CookieChat
//
//  Created by Chao Liang on 8/10/2016.
//  Copyright © 2016 Chao. All rights reserved.
//

import UIKit

class ContactTableViewCell: UITableViewCell {
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var lastTimeLabel: UILabel!
    @IBOutlet var contactImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
