//
//  VideoTableViewController.swift
//  AOLProject
//
//  Created by Eric Herring on 3/30/17.
//  Copyright © 2017 EKJ. All rights reserved.
//

import UIKit
import SDWebImage
import AVFoundation
import AVKit

class VideoTableViewController: UITableViewController {

    var videoData:Array<Video>! = []
    var currentURL:String!
    var currentName:String!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Fetch the data
        getData(urlAddress: "https://api.bantr.co/video/getFeatured")

    }
    
    func getData(urlAddress : String)
    {
        // Asynchronous Http call using NSURLSession:
        guard let url = URL(string: urlAddress) else
        {
            print("Url conversion issue.")
            return
        }
        URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) -> Void in
            // Check if data was received successfully
            do {
                if let data = data,
                    let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                    let response = json["response"] as? [[String: Any]] {
                    
                    // Loop through the data
                    for info in response {
                        let video = Video()
                        print(info)
                        if (info["description"] as? String) != nil {
                            video.description = info["description"] as! String
                            video.descriptionAvailable = true;
                        }
                        //video.description = info["description"] as! String
                        video.length = info["length"] as! Int
                        video.name = info["name"] as! String
                        video.videoURL = info["url"] as! String
                        video.staticImageUrl = info["staticImageUrl"] as! String
                        let productsArray = info["products"] as! NSArray
                        if(productsArray.count > 0) {
                            var dict = productsArray[0] as! Dictionary<String, Any>
                            video.manufacturer = dict["manufacturerBrand"] as! String
                        }
                        self.videoData.append(video)
                    }
                    DispatchQueue.main.sync() {
                        self.tableView.reloadData()
                    }
                    
                }
            } catch {
                print("Error deserializing JSON: \(error)")
            }
            
        }).resume()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videoData.count
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // Only one section
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "VideoTableViewCell") as! VideoTableViewCell
        
        let video = videoData[indexPath.row]
        cell.nameLabel?.text = video.name
        let url : NSString = video.staticImageUrl as NSString
        let urlStr = url.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)
        
        // Use SDWebImage to get the images
        cell.videoImageView.sd_setImage(with: URL(string: urlStr! as String), placeholderImage: UIImage(named: "placeholder.png"), options: SDWebImageOptions(rawValue: 0), completed: { (image, error, cacheType, imageURL) in
            // Perform operation.
            if(error != nil) {
                print(error!.localizedDescription)
            }
        })
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapImage(_:)))
        cell.videoImageView.addGestureRecognizer(tapGesture)
        cell.videoImageView.isUserInteractionEnabled = true
        cell.videoImageView.tag = indexPath.row
        
        // Set the manufacturer label
        if video.manufacturer != "" {
            cell.byLabel.text = "by: " + video.manufacturer
        }
        cell.selectionStyle = .none
        return cell;
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Allow user to edit the cells
        return true;
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destination = segue.destination as! AVPlayerViewController
        let url = URL(string: currentURL)

        destination.player = AVPlayer(url: url!)
        destination.title = currentName
        destination.player?.play()
        
    }
    
    func tapImage(_ sender: UITapGestureRecognizer) {
        let video = videoData[sender.view!.tag]
        currentURL = video.videoURL
        currentName = video.name
        
        self.performSegue(withIdentifier: "playVideo", sender: self)
    }

}
