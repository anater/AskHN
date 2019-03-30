//
//  ViewController.swift
//  AskHN
//
//  Created by Andrew Nater on 3/27/19.
//  Copyright © 2019 Andrew Nater. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
   
    let api = HackerNewsAPI()
    var data = [HNItem]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadList()
        
        tableView.rowHeight = UITableView.automaticDimension
    }
    
    func loadList() {
        api.getAskStories { items, error in
            if let items = items {
                self.loadItems(items: items)
            } else if error != nil {
                print("Error loading list")
            }
        }
    }
    
    func loadItems(items: [Int]) {
        api.getItems(for: items) { (itemResponses, error) in
            guard error == nil else {
                print(error!)
                return
            }
            // if we got items...
            if let itemResponses = itemResponses,
                itemResponses.count > 0 {
                // do something wtih responses
                self.data = itemResponses
                self.tableView.reloadData()
            }
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "story", for: indexPath)
        guard let storyCell = cell as? StoryTableViewCell else { return cell }

        let storyData = data[indexPath.row]
       
        // format date
        let date = Date(timeIntervalSince1970: TimeInterval(storyData.time))
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.autoupdatingCurrent
        dateFormatter.locale = NSLocale.autoupdatingCurrent
        dateFormatter.dateFormat = "MMM d 'at' h:mm a" //Specify your format that you want
        let timestamp = dateFormatter.string(from: date)
        
        // set up label text
        storyCell.titleLabel?.text = storyData.title
        storyCell.subtitleLabel?.text = "\(storyData.score) points | \(storyData.descendants) comments | \(timestamp)"
        
        return storyCell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyData = data[indexPath.row]
//        let vc = StoryTableViewController(story: storyData)
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        if let vc = storyboard.instantiateViewController(withIdentifier: "storyDetail") as? StoryTableViewController {
            vc.story = storyData
            navigationController?.show(vc, sender: nil)
        } else {
            print("something went wrong showing story")
        }
    }
}

