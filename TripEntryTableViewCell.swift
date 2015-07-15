//
//  TripEntryTableViewCell.swift
//  TripMate
//
//  Created by Rao on 7/8/15.
//  Copyright (c) 2015 Rao. All rights reserved.
//

import UIKit

class TripEntryTableViewCell: UITableViewCell {
    @IBOutlet var infoLabel: UILabel!
    @IBOutlet var pictureView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
