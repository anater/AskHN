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
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
