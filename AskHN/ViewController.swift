//
//  ViewController.swift
//  AskHN
//
//  Created by Andrew Nater on 3/27/19.
//  Copyright © 2019 Andrew Nater. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    
    let data = ["one", "two", "three"]

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        loadList()
    }
    
    func loadList() {
        HackerNewsAPI().ask { data, error in
            self.loadItems(items: data as! Array<Int>)
        }
    }
    
    func loadItems(items: Array<Int>) {
     dump(items)
        // TODO: use DispatchGroup to keep track of when all requested items have been loaded
        // – need to keep track of a collection of the responses as the complete
        // – need to execute on all the responses once they are available
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "story", for: indexPath)
        if let storyCell = cell as? StoryTableViewCell {
            storyCell.titleLabel?.text = "Title: \(data[indexPath.row])"
            storyCell.subtitleLabel?.text = "Subtitle: \(data[indexPath.row])"
            return storyCell
        } else {
            // fallback
            cell.textLabel?.text = data[indexPath.row]
            return cell
        }
    }
}

