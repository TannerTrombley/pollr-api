//
//  PollQuestionTableViewCell.swift
//  Scrolling
//
//  Created by David Hendershot on 10/27/16.
//  Copyright © 2016 Pollr. All rights reserved.
//

import UIKit
import Firebase

class PollQuestionTableViewCell: UITableViewCell {
	
	// Used to supress NSException thrown when you try to removeObserver before addObvserver gets called
	var observerAdded = false
	
	// MARK: Cell Heights
	class var defaultHeight: CGFloat { get { return 50 } }
	class var expandedHeight: CGFloat { get { return 175 } }
	
	// MARK: Cell Contents
	@IBOutlet weak var pollTitle: UILabel!
	@IBOutlet weak var responseStack: UIStackView!
	
	
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
		let selectedAnswer = sender.titleLabel?.text
		let pollId = sender.tag
		
		for view in responseStack.subviews {
			if let button = view as? UIButton {
				button.titleLabel?.text = "You have already voted"
			}
		}
		
//		print("The user voted for \((sender.titleLabel?.text)!) on poll \(sender.tag)")
		
		let currentUser = FIRAuth.auth()?.currentUser
		currentUser?.getTokenForcingRefresh(true) {idToken, error in
			if let error = error {
				print(error)
				return;
			}
			
			let client = clientAPI(token: idToken!)
			client.voteOnPoll(pollId: pollId, userVote: selectedAnswer!)
		}
	}
	
	
}
