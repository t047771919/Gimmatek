//
//  GimmatekCollectionViewController.swift
//  Gimmatek
//
//  Created by 林建勳 on 2017/12/8.
//  Copyright © 2017年 林建勳. All rights reserved.
//

import UIKit

//private let reuseIdentifier = "CollectionCell"

class GimmatekCollectionViewController: UICollectionViewController,URLSessionDelegate {
    let url = "https://hahago-api-tesla.appspot.com/fortest/api/"
    var gimmateks = [Gimmatek]()
    lazy var session: URLSession = {
        return URLSession(configuration: URLSessionConfiguration.default)
    }()
    // 取得螢幕的尺寸
    let fullScreenSize = UIScreen.main.bounds.size
    // 修改photo尺寸
    let reSize = CGSize(width: 310, height: 300)
    // 修改Bighoto尺寸
    let reBigSize = CGSize(width: 310, height: 800)

    
    let parameters = [
        "userlat":24.7844431,
        "userlng":121.0172038
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        getLatestGimmateks()
        let flowLayout = self.collectionViewLayout as! UICollectionViewFlowLayout
        flowLayout.estimatedItemSize = CGSize(width: 100, height: 100)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return gimmateks.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionCell", for: indexPath) as! GimmatekCollectionViewCell
        cell.userPhotoImageCollectionViewCell.layer.cornerRadius = cell.userPhotoImageCollectionViewCell.frame.size.width / 2
        cell.userPhotoImageCollectionViewCell.clipsToBounds = true
        // Configure the cell
        let gimmatek = gimmateks[indexPath.row]
            let cacheUserPhoto = NSURL(string: gimmatek.userPhoto!)
            cell.cacheImage = cacheUserPhoto // For recycled cells' late image loads.
            if let image = cacheUserPhoto?.cachedImage {
                cell.userPhotoImageCollectionViewCell.image = image
                cell.userPhotoImageCollectionViewCell.alpha = 1
            } else { //沒抓過 ->下載圖片
                cell.userPhotoImageCollectionViewCell.alpha = 0
                // 下載圖片
                cacheUserPhoto?.fetchImage { image in
                    // Check the cell hasn't recycled while loading.
                    if cell.cacheImage == cacheUserPhoto {
                        cell.userPhotoImageCollectionViewCell.image = image
                        UIView.animate(withDuration: 0.3) {
                            cell.userPhotoImageCollectionViewCell.alpha = 1
                        }
                    }
                    collectionView.reloadData()
                }
            }
            let cachePhoto = NSURL(string: gimmatek.photo!)
            cell.cacheImage = cachePhoto // For recycled cells' late image loads.
            if let image = cachePhoto?.cachedImage {
                if image.size.height == 1396 {
                    cell.photoImageCollectionViewCell.image = image.reSizeImage(reSize: self.reBigSize)
                    cell.photoImageCollectionViewCell.alpha = 1
                }else{
                    cell.photoImageCollectionViewCell.image = image.reSizeImage(reSize: self.reSize)
                }
            } else { //沒抓過 ->下載圖片
                cell.photoImageCollectionViewCell.alpha = 0
                // 下載圖片
                cachePhoto?.fetchImage { image in
                    // Check the cell hasn't recycled while loading.
                    if cell.cacheImage == cachePhoto {
                        cell.photoImageCollectionViewCell.image = image.reSizeImage(reSize: self.reSize)
                        UIView.animate(withDuration: 0.3) {
                            cell.photoImageCollectionViewCell.alpha = 1
                        }
                    }
                    collectionView.reloadData()
                }
            }
            cell.nameLabelCollectionViewCell.text = gimmatek.name
            cell.uidtimeDiffdistanceLabelCollectionViewCell.text = gimmatek.uid! + "." + gimmatek.timeDiff! + "." + gimmatek.distance!
            cell.bodyLabelCollectionViewCell.text = gimmatek.body
        
        // add border and color
        cell.backgroundColor = UIColor.white
        cell.layer.borderColor = UIColor.black.cgColor
        cell.layer.borderWidth = 1
        cell.layer.cornerRadius = 8
        cell.clipsToBounds = true
        
        return cell
    }
    
    // MARK: - JSON Parsing
    
    
    func getLatestGimmateks() {
        
        guard let gimmateklUrl = URL(string: url) else {
            return
        }
        var request = URLRequest(url: gimmateklUrl)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else { return }
        request.httpBody = httpBody
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
            
            if let error = error {
                print(error)
                return
            }
            
            // Parse JSON data
            if let data = data {
                self.gimmateks = self.parseJSONData(data: data)
                
                // Reload table view
                OperationQueue.main.addOperation ({
                    self.collectionView?.reloadData()
                })
            }
        })
        task.resume()
        
    }
    
    func parseJSONData(data: Data) -> [Gimmatek] {
        
        do {
            
            let jsonResult = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary
            
            // 解析 JSON 資料
            let jsonfeeds = jsonResult?["feeds"] as! [AnyObject]
            for jsongimmatek in jsonfeeds {
                let gimmatek = Gimmatek()
                if jsongimmatek["userPhoto"] != nil {
                    gimmatek.userPhoto = jsongimmatek["userPhoto"] as? String

                }
                if jsongimmatek["name"] != nil {
                    gimmatek.name = jsongimmatek["name"] as? String

                }
                if jsongimmatek["uid"] != nil {
                    gimmatek.uid = jsongimmatek["uid"] as? String

                }
                if jsongimmatek["timeDiff"] != nil {
                    gimmatek.timeDiff = jsongimmatek["timeDiff"] as? String

                }
                if jsongimmatek["distance"] != nil {
                    gimmatek.distance = jsongimmatek["distance"] as? String

                }
                if jsongimmatek["body"] != nil {
                    gimmatek.body = jsongimmatek["body"] as? String

                }
                if jsongimmatek["photo"] != nil {
                    gimmatek.photo = jsongimmatek["photo"] as? String

                }
//                gimmatek.userPhoto = jsongimmatek["userPhoto"] as! String
//                gimmatek.name = jsongimmatek["name"] as! String
//                gimmatek.uid = jsongimmatek["uid"] as! String
//                gimmatek.timeDiff = jsongimmatek["timeDiff"] as! String
//                gimmatek.distance = jsongimmatek["distance"] as! String
//                gimmatek.body = jsongimmatek["body"] as! String
//                gimmatek.photo = jsongimmatek["photo"] as! String
                gimmateks.append(gimmatek)
            }
        } catch {
            print(error)
        }
        return gimmateks
        
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
