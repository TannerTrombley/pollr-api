//
//  SubmitCommentTableViewCell.swift
//  Scrolling
//
//  Created by David Hendershot on 12/2/16.
//  Copyright © 2016 Pollr. All rights reserved.
//

import UIKit

class SubmitCommentTableViewCell: UITableViewCell {

	@IBOutlet weak var userComment: UITextField!
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
