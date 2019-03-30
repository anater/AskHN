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
    var data = [Any]() // TODO: use an actual Story type here...

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadList()
        
        tableView.rowHeight = UITableView.automaticDimension
    }
    
    func loadList() {
        api.ask { data, error in
            self.loadItems(items: data as! Array<Int>)
        }
    }
    
    func loadItems(items: Array<Int>) {
        api.items(ids: items) { (itemResponses, error) in
            if error != nil {
                print(error!)
                return
            }
            // do something wtih responses
            print("responses")
            self.data = itemResponses as! [Any]
            self.tableView.reloadData()
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "story", for: indexPath)
        if let storyCell = cell as? StoryTableViewCell {
            let storyData = data[indexPath.row] as AnyObject
            let title = storyData["title"] as! String
            let points = storyData["score"] as! Int
            let comments = storyData["descendants"] as! Int
            let time = storyData["time"] as! Int
            let date = Date(timeIntervalSince1970: TimeInterval(time))
            let dateFormatter = DateFormatter()
            dateFormatter.locale = NSLocale.current
            dateFormatter.dateFormat = "MMM d 'at' h:mm a" //Specify your format that you want
            let timestamp = dateFormatter.string(from: date)
            // points | comments | timestamp
            storyCell.titleLabel?.text = title
            storyCell.subtitleLabel?.text = "\(points) points | \(comments) comments | \(timestamp)"
            return storyCell
        } else {
            // fallback
            return cell
        }
    }
}

