//
//  GimmatekCollectionViewCell.swift
//  Gimmatek
//
//  Created by 林建勳 on 2017/12/8.
//  Copyright © 2017年 林建勳. All rights reserved.
//

import UIKit

class GimmatekCollectionViewCell: UICollectionViewCell {
    @IBOutlet var userPhotoImageCollectionViewCell: UIImageView!
    @IBOutlet var nameLabelCollectionViewCell: UILabel!
    @IBOutlet var uidtimeDiffdistanceLabelCollectionViewCell: UILabel!
    @IBOutlet var bodyLabelCollectionViewCell: UILabel!
    @IBOutlet var photoImageCollectionViewCell: UIImageView!
    var cacheImage: NSURL!
}
