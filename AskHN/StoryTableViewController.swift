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
    let dispatchGroup = DispatchGroup()
    
    var story: HNItem?
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
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareStory))
        
        tableView.estimatedRowHeight = 500
        
        if let items = story?.kids {
            loadComments(for: items)
        }
        
        dispatchGroup.notify(queue: .main) { [unowned self] in
            self.structureCommentsForTableView()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.navigationBar.prefersLargeTitles = true
        super.viewDidDisappear(animated)
    }
    
    func sendLinkToActivityVC(for id: Int) {
        if let url = URL(string: "https://news.ycombinator.com/item?id=\(id)") {
            let ac = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            present(ac, animated: true)
        }
    }
    
    @objc func shareStory() {
        if let id = story?.id {
            sendLinkToActivityVC(for: id)
        } else {
            let ac = UIAlertController(title: "No story ID", message: "Unable to share this story.", preferredStyle: .alert)
            present(ac, animated: true)
        }
    }
    
    func loadComments(for items: [Int]) {
        dispatchGroup.enter()
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
                for comment in comments {
                    self.commentsById.updateValue(comment, forKey: comment.id)
                    // if we have kids, load those items, incremement indentation level
                    if let kids = comment.kids, kids.count > 0 {
                        self.loadComments(for: kids)
                    }
                }
            }
            
            self.dispatchGroup.leave()
        }
    }
    
    func structureCommentsForTableView() {
        // starting with story.kids
        if let kids = story?.kids {
            addComments(from: kids, indent: 1) { [unowned self] in
                self.tableView.reloadData()
            }
        }
    }
    
    func addComments(from ids: [Int], indent: Int, completionHandler: (() -> Void)?) {
        for id in ids {
            orderedComments.append([id : indent])
            let comment = commentsById[id]
            if let granKids = comment?.kids, granKids.count > 0 {
                addComments(from: granKids, indent: indent + 1, completionHandler: nil)
            }
        }
        if let handler = completionHandler {
            handler()
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
                cell.bodyLabel.attributedText = getAttributedString(from: Data(story?.text?.utf8 ?? "".utf8))
                return cell
            }
        } else if let cell = tableView.dequeueReusableCell(withIdentifier: "storyComment") as? StoryCommentTableViewCell {
            let data = orderedComments[indexPath.row - 1]
            let comment = commentsById[data.first!.key]
            let text = comment?.text ?? ""
            // update cell content
            cell.textView?.attributedText = getAttributedString(from: Data(text.utf8))
            cell.subtitleLabel?.text = comment?.by
            // update cell indent
            cell.indentationLevel = data.first!.value
            let separatorIndent = CGFloat(cell.indentationLevel) * cell.indentationWidth
            cell.separatorInset = UIEdgeInsets(top: 0, left: separatorIndent, bottom: 0, right: 0)

            return cell
        }
        // none of the above? return empty cell
        return UITableViewCell()
    }
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return UITableView.automaticDimension
	}
    
    func getAttributedString(from html: Data) -> NSAttributedString {
        let options: [NSMutableAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSMutableAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        if let attributedString = try? NSMutableAttributedString(data: html, options: options, documentAttributes: nil) {
            attributedString.addAttribute(.font,
                                          value: UIFont.preferredFont(forTextStyle: .body),
                                          range: NSRange(location: 0, length: attributedString.length))
            return attributedString.trimmedAttributedString(set: .whitespacesAndNewlines)
        } else {
            return NSAttributedString()
        }
    }
}

// From StackOverflow: https://stackoverflow.com/questions/34081197/how-to-trimremove-white-spaces-from-end-of-a-nsattributedstring
extension NSMutableAttributedString {
    
    func trimmedAttributedString(set: CharacterSet) -> NSMutableAttributedString {
        
        let invertedSet = set.inverted
        
        var range = (string as NSString).rangeOfCharacter(from: invertedSet)
        let loc = range.length > 0 ? range.location : 0
        
        range = (string as NSString).rangeOfCharacter(
            from: invertedSet, options: .backwards)
        let len = (range.length > 0 ? NSMaxRange(range) : string.count) - loc
        
        let r = self.attributedSubstring(from: NSMakeRange(loc, len))
        return NSMutableAttributedString(attributedString: r)
    }
}
