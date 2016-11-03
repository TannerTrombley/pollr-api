//
//  PollAnswersTableViewCell.swift
//  Scrolling
//
//  Created by David Hendershot on 10/28/16.
//  Copyright © 2016 Pollr. All rights reserved.
//

import UIKit

class PollAnswersTableViewCell: UITableViewCell {

	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
		let button = UIButton(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
		addSubview(button)
		
		print("Set selected")
    }

}
