//
//  GimmatekTableViewCell.swift
//  Gimmatek
//
//  Created by 林建勳 on 2017/12/2.
//  Copyright © 2017年 林建勳. All rights reserved.
//

import UIKit

class GimmatekTableViewCell: UITableViewCell {
    @IBOutlet var userPhotoImage: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var uidtimeDiffdistanceLabel: UILabel!
    @IBOutlet var bodyLabel: UILabel!
    @IBOutlet var photoImage: UIImageView!
    var ivPhoto: NSURL!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
