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
