//
//  PollQuestionTableViewCell.swift
//  Scrolling
//
//  Created by David Hendershot on 10/27/16.
//  Copyright © 2016 Pollr. All rights reserved.
//

import UIKit

class PollQuestionTableViewCell: UITableViewCell {
	
	var observerAdded = false
	
	// MARK: Heights
	class var defaultHeight: CGFloat { get { return 44 } }
	class var expandedHeight: CGFloat { get { return 250 } }
	
	// MARK: Cell Contents
	@IBOutlet weak var pollTitle: UILabel!
	
	@IBOutlet weak var responseStack: UIStackView!
	
	@IBOutlet weak var firstResponse: UIButton!
	@IBOutlet weak var secondResponse: UIButton!
	@IBOutlet weak var thirdResponse: UIButton!
	@IBOutlet weak var fourthResponse: UIButton!
	
	
	// MARK: User Votes Actions
	@IBAction func userVotesFirstResponse(_ sender: UIButton) {
		// Send vote to server
		// Show the user the results of the poll
	}

	@IBAction func userVotesSecondReponse(_ sender: UIButton) {
		
	}
	
	@IBAction func userVotesThirdResponse(_ sender: UIButton) {
		
	}
	
	@IBAction func userVotesFourthResponse(_ sender: UIButton) {
		
	}
	
	
	func checkHeight() {
		if frame.size.height < PollQuestionTableViewCell.expandedHeight {
			responseStack.isHidden = true
		} else {
			responseStack.isHidden = false
		}
	}
	
	func watchFrameChanges() {
		addObserver(self, forKeyPath: "frame", options: .new, context: nil)
		observerAdded = true
		checkHeight() 
	}
	
	func ignoreFrameChanges() {
		if observerAdded {
			removeObserver(self, forKeyPath: "frame")
			observerAdded = false
		}
	}
	
	override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
		if keyPath == "frame" {
			 checkHeight()
		}
	}
	
	func userCastedVote(_ sender: UIButton) {
		// Dispatch request based on how they voted
		print("The user voted for \(sender.titleLabel?.text)")
	}
	
	
}
