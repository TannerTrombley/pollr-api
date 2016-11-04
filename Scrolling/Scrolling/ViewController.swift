//
//  ViewController.swift
//  Scrolling
//
//  Created by David Hendershot on 10/27/16.
//  Copyright © 2016 Pollr. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

	var cellTapped = true
	var selectedIndexPath: IndexPath?
	var pollId: Int?
	
	var questions = [String]()
	var locations = [String]()
	var answers = [String]()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		Alamofire.request("https://pollr-api.appspot.com/api/v1.0/demo")
		
		pollId = 0
		
		// Turns out these requests could be dispatched in prepareForSeque by the instigator viewController
//		questions = requestClientClass.pleaseGetSomePollTitles(myLocation or sumptin)
		
		questions = ["What are your spring break plans?",
		             "How do you feel about the deer cull in A2?",
		             "Best first date restaurant?",
		             "Floss before or after brushing?",
		             "How often do you utilize public transport?"]
		
		locations = ["UofM",
		             "Ann Arbor",
		             "Ann Arbor",
		             "USA",
		             "Michigan"]
		
		answers = ["Yes", "No", "Maybe", "Decline to answer"]
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
//			print("Need to reload rows: \(indexPaths)")
			tableView.reloadRows(at: indexPaths, with: UITableViewRowAnimation.automatic)
		}
	}
	
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return questions.count
	}
	
	// Setup the cell with the appropriate number of responses
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCell(withIdentifier: "PollQuestionTableViewCell", for: indexPath) as? PollQuestionTableViewCell
		let responseStack = cell?.contentView.viewWithTag(1) as! UIStackView
		
		if responseStack.subviews.isEmpty {

//			answers = httpsClient.getAnswersForPoll('poll-id')
			
			for answer in answers {
				// Create button
				let button = UIButton(type: UIButtonType.system)
				button.setTitle(answer, for: UIControlState.normal)
				
				// Give it an action
				button.addTarget(cell, action: #selector(PollQuestionTableViewCell.userCastedVote(_:)), for: UIControlEvents.touchUpInside)
				
				// Add button to the stack of selectable repsonses
				responseStack.addArrangedSubview(button)
				
				// Constrain it to the leading edge of the stack (i'm not sure why it's showing up in the center, but that works too)
				button.trailingAnchor.constraint(equalTo: responseStack.layoutMarginsGuide.trailingAnchor).isActive = true
			}
		}
		let row = indexPath.row
		cell?.pollTitle.text = questions[row]
		return cell!

	}
	
	func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		(cell as! PollQuestionTableViewCell).watchFrameChanges()
	}
	
	func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		(cell as! PollQuestionTableViewCell).ignoreFrameChanges()
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if indexPath == selectedIndexPath {
			return PollQuestionTableViewCell.expandedHeight
		} else {
			return PollQuestionTableViewCell.defaultHeight
		}
	}
}

