//
//  GimmatekImageCache.swift
//  Gimmatek
//
//  Created by 林建勳 on 2017/12/4.
//  Copyright © 2017年 林建勳. All rights reserved.
//

import UIKit

class CustomImageCache {
    
    static let sharedCache: NSCache = { () -> NSCache<AnyObject, AnyObject> in
        let cache = NSCache<AnyObject, AnyObject>()
        cache.name = "MyImageCache"
        cache.countLimit = 20 // Max 20 images in memory.
        cache.totalCostLimit = 10*1024*1024 // Max 10MB used.
        return cache
    }()
    
}

extension NSURL {
    
    typealias ImageCacheCompletion = (UIImage) -> Void
    
    
    var cachedImage: UIImage? {
        return CustomImageCache.sharedCache.object(
            forKey: absoluteString as AnyObject) as? UIImage
    }
    
    func fetchImage(completion: @escaping ImageCacheCompletion) {
        // 如果需要客製化取得資料在此做
        let task = URLSession.shared.dataTask(with: self as URL) {
            data, response, error in
            if error == nil {
                if let data = data, let image = UIImage(data: data) {
                    CustomImageCache.sharedCache.setObject(
                        image,
                        forKey: self.absoluteString as AnyObject,
                        cost: data.count)
                    DispatchQueue.main.async() {
                        completion(image)
                    }
                }
            }
        }
        task.resume()
    }
    
}
