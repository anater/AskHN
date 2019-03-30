//
//  StoryDetailTableViewCell.swift
//  AskHN
//
//  Created by Andrew Nater on 3/30/19.
//  Copyright © 2019 Andrew Nater. All rights reserved.
//

import UIKit

class StoryDetailTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
