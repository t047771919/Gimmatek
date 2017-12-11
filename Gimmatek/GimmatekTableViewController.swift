//
//  GimmatekTableViewController.swift
//  Gimmatek
//
//  Created by 林建勳 on 2017/12/2.
//  Copyright © 2017年 林建勳. All rights reserved.
//

import UIKit

class GimmatekTableViewController: UITableViewController,URLSessionDelegate {
    
    let url = "https://hahago-api-tesla.appspot.com/fortest/api/"
    var gimmateks = [Gimmatek]()
    lazy var session: URLSession = {
        return URLSession(configuration: URLSessionConfiguration.default)
    }()
    // 取得螢幕的尺寸
    let fullScreenSize = UIScreen.main.bounds.size
    // 修改photo尺寸
    let reSize = CGSize(width: 323, height: 150)
 
    let parameters = [
        "userlat":24.7844431,
        "userlng":121.0172038
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        getLatestGimmateks()
//        self.tableView.rowHeight = UITableViewAutomaticDimension
//        self.tableView.estimatedRowHeight = 100

    

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return gimmateks.count
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let cellSpacingHeight: CGFloat = 5
        return cellSpacingHeight
    }
    // Make the background color show through
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: GimmatekTableViewCell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! GimmatekTableViewCell
        
        let gimmatek = gimmateks[indexPath.row]
        // Configure the cell...
        if let url = URL(string: gimmatek.userPhoto) {
            let downloadImageTask = session.dataTask(with: url, completionHandler: { (data, responsn, error) in
                if error != nil {
                    return
                }
                if let okData = data {
                    let image = UIImage(data: okData)
                    DispatchQueue.main.async {
                        cell.userPhotoImage.image = image
                    }
                }
            })
            downloadImageTask.resume()
        }
            let ivPhoto = NSURL(string: gimmatek.photo)
            cell.ivPhoto = ivPhoto // For recycled cells' late image loads.
            if let image = ivPhoto?.cachedImage {
                cell.photoImage.image = image.reSizeImage(reSize: self.reSize)
//                cell.photoImage.image = image
                cell.photoImage.alpha = 1
            } else { //沒抓過 ->下載圖片
                cell.photoImage.alpha = 0
                // 下載圖片
                ivPhoto?.fetchImage { image in
                    // Check the cell hasn't recycled while loading.
                    if cell.ivPhoto == ivPhoto {
                        cell.photoImage.image = image.reSizeImage(reSize: self.reSize)
                        cell.photoImage.image = image
                        UIView.animate(withDuration: 0.3) {
                        cell.photoImage.alpha = 1
                        }
                    }
                    tableView.reloadData()
                }
            }
        cell.nameLabel.text = gimmatek.name
        cell.uidtimeDiffdistanceLabel.text = gimmatek.uid + "." + gimmatek.timeDiff + "." + gimmatek.distance
        cell.bodyLabel.text = gimmatek.body

        // add border and color
        cell.backgroundColor = UIColor.white
        cell.layer.borderColor = UIColor.black.cgColor
        cell.layer.borderWidth = 1
        cell.layer.cornerRadius = 8
        cell.clipsToBounds = true
        
        return cell
    }


    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */
    
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
                    self.tableView.reloadData()
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
                gimmatek.userPhoto = jsongimmatek["userPhoto"] as! String
                gimmatek.name = jsongimmatek["name"] as! String
                gimmatek.uid = jsongimmatek["uid"] as! String
                gimmatek.timeDiff = jsongimmatek["timeDiff"] as! String
                gimmatek.distance = jsongimmatek["distance"] as! String
                gimmatek.body = jsongimmatek["body"] as! String
                gimmatek.photo = jsongimmatek["photo"] as! String
                gimmateks.append(gimmatek)
                print(gimmatek.name,gimmatek.photo)
            }
        } catch {
            print(error)
        }
        return gimmateks
        
    }

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
