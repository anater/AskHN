//
//  StoryTableViewController.swift
//  AskHN
//
//  Created by Andrew Nater on 3/30/19.
//  Copyright © 2019 Andrew Nater. All rights reserved.
//

import UIKit

class StoryTableViewController: UITableViewController {
    
    var story: HNItem?
    var comments = [HNItem]()
    
    init(story: HNItem) {
        self.story = story
        super.init(style: .plain)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.navigationBar.prefersLargeTitles = true
        super.viewDidDisappear(animated)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count + 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "story") as? StoryTableViewCell {
                cell.titleLabel.text = story?.title
                cell.subtitleLabel.text = story?.by
                return cell
            } else {
                print("could not find story cell for index path")
            }
        }

        return tableView.cellForRow(at: indexPath)!
    }
}
