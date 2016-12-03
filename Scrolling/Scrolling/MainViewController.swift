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

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, VotedOn {

	var cellTapped = true
	var selectedIndexPath: IndexPath?
	
	var polls = [Poll]()
	
	
	@IBOutlet weak var table: UITableView!
	
	func done(polls: [Poll]) {
		self.polls = polls
		
		DispatchQueue.main.async {
			self.table.reloadData()
		}
	}
	
	// Once the points are retrieved from the server update the button
	func done(points: Int) {
		
		if let navBar = self.navigationController?.navigationBar {
			for view in navBar.subviews {
				if let label = view as? UILabel {
					label.text = "Points: \(points)"
					
					if label.alpha == 0.0 {
						UIView.animate(withDuration: 0.5, animations: {
							label.alpha = 1.0
						})
					} else {
						let pulseAnimation:CABasicAnimation = CABasicAnimation(keyPath: "transform.scale")
						pulseAnimation.duration = 1.0
						pulseAnimation.toValue = NSNumber(value: 1.0)
						pulseAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
						pulseAnimation.autoreverses = true
						pulseAnimation.repeatCount = FLT_MAX
						label.layer.add(pulseAnimation, forKey: nil)
					}
				}
			}
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
	
//		self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.action, target: nil, action: nil)

		if let navigationBar = self.navigationController?.navigationBar {
			
			let buttonFrame = CGRect(x: navigationBar.frame.width - navigationBar.frame.width/4, y: 1, width: navigationBar.frame.width/2, height: navigationBar.frame.height)
			
			let firstLabel = UILabel(frame: buttonFrame)
			firstLabel.text = "Points: "
			firstLabel.alpha = 0.0
			navigationBar.addSubview(firstLabel)
			
			
			
			let currentUser = FIRAuth.auth()?.currentUser
			currentUser?.getTokenForcingRefresh(true) {idToken, error in
				if let error = error {
					print(error)
					return;
				}
				
				let client = clientAPI(token: idToken!)
				client.getPoints(done: self.done)
			}
		}
		
		
		let currentUser = FIRAuth.auth()?.currentUser
		currentUser?.getTokenForcingRefresh(true) {idToken, error in
			if let error = error {
				print(error)
				return;
			}
			
			let client = clientAPI(token: idToken!)
			client.getPolls(latitude: 42.2808, longitude: 83.7430, done: self.done)
		}
	}
	
	override func viewWillAppear(_ animated: Bool) {
		let currentUser = FIRAuth.auth()?.currentUser
		currentUser?.getTokenForcingRefresh(true) {idToken, error in
			if let error = error {
				print(error)
				return;
			}
			
			let client = clientAPI(token: idToken!)
			client.getPolls(latitude: 42.2808, longitude: 83.7430, done: self.done)
			client.getPoints(done: self.done)
		}
	}
	
	
	func didVoteOnPoll(id: Int) {
		for i in 0..<polls.count {
			if polls[i].getId() == id {
				polls[i].setVote(vote: true)
				if let path = self.selectedIndexPath {
					table.reloadRows(at: [path], with: UITableViewRowAnimation.automatic)
				}
			}
		}
		
		func refreshPoints(points: Int) {
			
			if let navBar = navigationController?.navigationBar {
				for view in navBar.subviews {
					if let label = view as? UILabel {
						let newPoints = points + 2
						label.text = "Points: \(newPoints)"
						
						UIView.animate(withDuration: 0.5, animations: {
							print("Animate 1")
							label.isHighlighted = true
						})
						
//						UIView.animate(withDuration: 0.5, animations: {
//							print("Animate 2")
//							label.isHighlighted = false
//						})
					}
				}
			}
		}

		// UPDATE POINTS
		let currentUser = FIRAuth.auth()?.currentUser
		currentUser?.getTokenForcingRefresh(true) {idToken, error in
			
			if let error = error {
				print(error)
				return;
			}
			
			let client = clientAPI(token: idToken!)
			client.getPoints(done: refreshPoints)
		}
		
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		
		if segue.identifier == "showPollResults",
			let button = sender as? UIButton,
			let destination = segue.destination as? PollResultsViewController
		{
			destination.pollId = button.tag
		}
	}
	
	
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
			tableView.reloadRows(at: indexPaths, with: UITableViewRowAnimation.automatic)
		}
	}
	
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return polls.count
	}
	
	// Retrieve the cell and populate the responses
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		let cell = tableView.dequeueReusableCell(withIdentifier: "PollQuestionTableViewCell", for: indexPath) as? PollQuestionTableViewCell
		cell?.cellDelegate = self
		
		let responseStack = cell?.contentView.subviews[1] as! UIStackView
		let row = indexPath.row
		cell?.resultsButton.tag = polls[row].getId()
		
		if !(polls[row].didVote()) {
			cell?.resultsButton.isHidden = true
		} else {
			cell?.resultsButton.isHidden = false
		}
		
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
		
		// Add dummy buttons for spacing
		for i in 0..<(4 - responseStack.subviews.count) {
			let button = UIButton(type: UIButtonType.system)
			button.isUserInteractionEnabled = false
			responseStack.addArrangedSubview(button)
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
			if let row = selectedIndexPath?.row, !(polls[row].hasVoted) {
				return PollQuestionTableViewCell.expandedHeight
			}
		}
		
		return PollQuestionTableViewCell.defaultHeight
	}
}

