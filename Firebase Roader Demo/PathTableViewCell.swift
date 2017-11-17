//
//  PathTableViewCell.swift
//  Firebase Roader Demo
//
//  Created by Harshit Singh on 10/24/17.
//  Copyright © 2017 RJT. All rights reserved.
//

import UIKit

class PathTableViewCell: UITableViewCell {

    @IBOutlet weak var mode_imageV: UIImageView!
    @IBOutlet weak var path_name_label: UILabel!
    @IBOutlet weak var distance_label: UILabel!
    @IBOutlet weak var time_label: UILabel!
    @IBOutlet weak var date_label: UILabel!
    @IBOutlet weak var user_count_label: UILabel!
    @IBOutlet weak var usercount_imageV: UIImageView!
    @IBOutlet weak var user_count_btn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
