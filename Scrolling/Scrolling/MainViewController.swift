//
//  ViewController.swift
//  Scrolling
//
//  Created by David Hendershot on 10/27/16.
//  Copyright © 2016 Pollr. All rights reserved.
//

import UIKit
import Alamofire
import Firebase

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

	var cellTapped = true
	var selectedIndexPath: IndexPath?
	
	var polls = [Poll]()
	
	@IBOutlet weak var table: UITableView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		func done(polls: [Poll]) {
			self.polls = polls.reversed()
			
			DispatchQueue.main.async {
				self.table.reloadData()
			}
		}
		
		let currentUser = FIRAuth.auth()?.currentUser
		currentUser?.getTokenForcingRefresh(true) {idToken, error in
			if let error = error {
				// Handle error
				return;
			}
			
			let client = clientAPI(token: idToken!)
			client.getDemoPolls(done: done)
		}
	}

	// Function that disables voting buttons on polls that have already been voted on
//	func disableVotingButtons(pollId: Int) {
//		// Get index of the poll in the polls array
//		
//		for i in 0..<polls.count {
//			if polls[i].getId() == pollId {
//				let path = [NSIndexPath(item: i, section: 0)]
//				self.polls.remove(at: i)
//				self.table.deleteRows(at: path as [IndexPath], with: UITableViewRowAnimation.left)
//			}
//		}
//	}
	
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let previousIndexPath = selectedIndexPath
		if indexPath == selectedIndexPath {
			selectedIndexPath = nil
		} else {
			selectedIndexPath = indexPath
		}
		
		// The rows that we need to reload when something expands/changes
		var indexPaths : Array<IndexPath> = []
		if let previous = previousIndexPath {
			indexPaths += [previous]
		}
		if let current = selectedIndexPath {
			indexPaths += [current]
		}
		
		if indexPaths.count > 0 {
//			print("Need to reload rows: \(indexPaths)")
			tableView.reloadRows(at: indexPaths, with: UITableViewRowAnimation.automatic)
		}
	}
	
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return polls.count
	}
	
	// Retrieve the cell and populate the responses
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		let cell = tableView.dequeueReusableCell(withIdentifier: "PollQuestionTableViewCell", for: indexPath) as? PollQuestionTableViewCell
		let responseStack = cell?.contentView.subviews[1] as! UIStackView
		let row = indexPath.row
		
		// Just remove all subviews to be sure
		let subViews = responseStack.subviews
		for view in subViews {
			view.removeFromSuperview()
		}
		
		// Only add the buttons for voting if they haven't already been loaded
		if responseStack.subviews.isEmpty {
			
			for answer in polls[row].getAnswers() {
				// Create button
				let button = UIButton(type: UIButtonType.system)
				button.setTitle(answer.key, for: UIControlState.normal)
				
				// Set the tag to the poll ID so the action knows which poll to set the vote to
				button.tag = polls[row].getId()
				
				// Give it an action
				button.addTarget(cell, action: #selector(PollQuestionTableViewCell.userCastedVote(_:)), for: UIControlEvents.touchUpInside)
				
				// Add button to the stack of selectable repsonses
				responseStack.addArrangedSubview(button)
				
				// Constrain it to the leading edge of the stack (i'm not sure why it's showing up in the center, but that works too)
				button.trailingAnchor.constraint(equalTo: responseStack.layoutMarginsGuide.trailingAnchor).isActive = true
			}
		}
		
		cell?.pollTitle.text = polls[row].getQuestion()
		return cell!
	}
	
	// Adds
	func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		(cell as! PollQuestionTableViewCell).watchFrameChanges()
	}
	
	//
	func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		(cell as! PollQuestionTableViewCell).ignoreFrameChanges()
	}
	
	// Return the cell's height
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if indexPath == selectedIndexPath {
			return PollQuestionTableViewCell.expandedHeight
		} else {
			return PollQuestionTableViewCell.defaultHeight
		}
	}
}

