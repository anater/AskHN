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
    // [ItemId: IndentLevel]
    var orderedComments = [[Int: Int]]()
    var commentsById = [Int: HNItem]()
    
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
        tableView.estimatedRowHeight = UITableView.automaticDimension
        
        if let items = story?.kids {
            loadComments(for: items, indentationLevel: 1, parentId: nil)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.navigationBar.prefersLargeTitles = true
        super.viewDidDisappear(animated)
    }
    
    func loadComments(for items: [Int], indentationLevel: Int, parentId: Int?) {
        print("Loading items", items)
        print("Indent", indentationLevel)
        // request items, then process data
        api.getItems(for: items) { [unowned self] (comments, error) in
            // exit if we have an error or no comments were returned
            guard error == nil else {
                print(error!)
                return
            }
            guard let comments = comments else {
                print("no comments")
                return
            }
            // if we do have comments, add them to our data structures
            if (comments.count > 0) {
                var commentsToInsert = [[Int: Int]]()
                for comment in comments {
                    self.commentsById.updateValue(comment, forKey: comment.id)
                    commentsToInsert.append([comment.id: indentationLevel])
                    // if we have kids, load those items, incremement indentation level
                    if let kids = comment.kids, kids.count > 0 {
                        self.loadComments(for: kids, indentationLevel: indentationLevel + 1, parentId: comment.id)
                    }
                }
                // insert comments into ordered comments array
                if indentationLevel == 0 {
                    self.orderedComments.append(contentsOf: commentsToInsert)
                } else if indentationLevel > 0, let parentId = parentId {
                    // get an index using the proper value for the parent comment data, insert the comment there
                    if let index = self.orderedComments.firstIndex(of: [parentId: indentationLevel - 1]) {
                        print(index)
                        self.orderedComments.insert(contentsOf: commentsToInsert, at: index + 1)
                    }
                }
            }
            // FIXME: need to use a dispatch group to reload once ALL data has loaded
            self.tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orderedComments.count + 1
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
            let data = orderedComments[indexPath.row - 1]
            let comment = commentsById[data.first!.key]
            
            cell.textView?.attributedText = getAttributedString(from: Data(comment?.text?.utf8 ?? "".utf8))!
            cell.subtitleLabel?.text = comment?.by
            cell.indentationLevel = data.first!.value

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
