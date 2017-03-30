//
//  VideoTableViewCell.swift
//  AOLProject
//
//  Created by Eric Herring on 3/30/17.
//  Copyright © 2017 EKJ. All rights reserved.
//

import UIKit

class VideoTableViewCell: UITableViewCell {

    @IBOutlet var videoImageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var lengthLabel: UILabel!
    @IBOutlet var byLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
