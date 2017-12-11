//
//  UIImage.swift
//  Gimmatek
//
//  Created by 林建勳 on 2017/12/6.
//  Copyright © 2017年 林建勳. All rights reserved.
//

import UIKit
//extension UIImage {
//    func resizeToSize(size: CGSize) -> UIImage {
//        UIGraphicsBeginImageContextWithOptions(size, false, 0) // change from UIGraphicsBeginImageContext(size) to suit scale > 1
//        self.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
//        let newImage = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//
//        return newImage!
//    }
//}
extension UIImage {
    /**
     *  重设图片大小
     */
    func reSizeImage(reSize:CGSize)->UIImage {
        //UIGraphicsBeginImageContext(reSize);
        UIGraphicsBeginImageContextWithOptions(reSize,false,UIScreen.main.scale);
        self.draw(in: CGRect(x: 0,y: 0, width: reSize.width, height: reSize.height))
        let reSizeImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return reSizeImage
    }
    
    /**
     *  等比率缩放
     */
    func scaleImage(scaleSize:CGFloat)->UIImage {
        let reSize = CGSize(width: self.size.width * scaleSize, height: self.size.height * scaleSize)
        return reSizeImage(reSize: reSize)
    }
}
