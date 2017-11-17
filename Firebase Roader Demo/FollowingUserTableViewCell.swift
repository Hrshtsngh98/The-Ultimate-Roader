//
//  FollowingUserTableViewCell.swift
//  Firebase Roader Demo
//
//  Created by Harshit Singh on 10/31/17.
//  Copyright © 2017 RJT. All rights reserved.
//

import UIKit

class FollowingUserTableViewCell: UITableViewCell {

    @IBOutlet weak var user_imageV: UIImageView!
    @IBOutlet weak var username_label: UILabel!
    @IBOutlet weak var usercity_label: UILabel!
    @IBOutlet weak var useremail_label: UILabel!
    @IBOutlet weak var path_count_label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        user_imageV.layer.cornerRadius = user_imageV.frame.height/2
        user_imageV.layer.borderWidth = 2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
