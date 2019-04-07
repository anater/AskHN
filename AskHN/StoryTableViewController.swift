//
//  StoryTableViewController.swift
//  AskHN
//
//  Created by Andrew Nater on 3/30/19.
//  Copyright © 2019 Andrew Nater. All rights reserved.
//

import UIKit

class StoryTableViewController: UITableViewController {
    
    let api = HackerNewsAPI()
    
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
        tableView.rowHeight = UITableView.automaticDimension

        loadComments()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.navigationBar.prefersLargeTitles = true
        super.viewDidDisappear(animated)
    }
    
    func loadComments() {
        guard let items = story?.kids else { return }
        api.getItems(for: items) { (comments, error) in
            guard error == nil else {
                print(error!)
                return
            }
            guard let comments = comments else {
                print("no comments")
                return
            }
            self.comments = comments
            self.tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count + 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "storyDetail") as? StoryDetailTableViewCell {
                cell.titleLabel.text = story?.title
                cell.subtitleLabel.text = story?.by ?? ""
                cell.bodyLabel.attributedText = getAttributedString(from: Data(story?.text?.utf8 ?? "".utf8))!
                return cell
            }
        } else if let cell = tableView.dequeueReusableCell(withIdentifier: "storyComment") as? StoryCommentTableViewCell {
            
            let comment = comments[indexPath.row - 1]
            cell.textView?.attributedText = getAttributedString(from: Data(comment.text?.utf8 ?? "".utf8))!
            cell.subtitleLabel?.text = comment.by

            return cell
        }
        // none of the above? return empty cell
        return UITableViewCell()
    }
    
    func getAttributedString(from html: Data) -> NSMutableAttributedString? {
        let options: [NSMutableAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSMutableAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        if let attributedString = try? NSMutableAttributedString(data: html,options: options, documentAttributes: nil) {
            attributedString.addAttribute(.font,
                                          value: UIFont.preferredFont(forTextStyle: .body),
                                          range: NSRange(location: 0, length: attributedString.length))
            return attributedString
        } else {
            return nil
        }
    }
}
