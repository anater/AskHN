//
//  StoryCommentTableViewCell.swift
//  AskHN
//
//  Created by Andrew Nater on 4/5/19.
//  Copyright © 2019 Andrew Nater. All rights reserved.
//

import UIKit

class StoryCommentTableViewCell: UITableViewCell {
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // reset insets
        textView.textContainerInset = UIEdgeInsets.zero
        textView.textContainer.lineFragmentPadding = 0
        indentationWidth = 20.0
        // style links
        textView.linkTextAttributes = [.foregroundColor: UIColor(red: 1.0, green: 0.4, blue: 0.0, alpha: 0.85)]
    }
    
    override func prepareForReuse() {
        subtitleLabel.textColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.contentView.layoutMargins.left = CGFloat(self.indentationLevel) * self.indentationWidth
        self.contentView.layoutIfNeeded()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
