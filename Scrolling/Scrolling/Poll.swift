//
//  Poll.swift
//  Scrolling
//
//  Created by David Hendershot on 11/4/16.
//  Copyright © 2016 Pollr. All rights reserved.
//

class Poll {
	var id : Int?
	var question: String?
	var answers: [String: Int]?
	var hasVoted : Bool
	
	init(id: Int, question: String, answers: [String: Int], voted: Bool) {
		self.id = id
		self.question = question
		self.answers = answers
		self.hasVoted = voted
	}
	
	func getId() -> Int {
		return id!
	}
	
	func getQuestion() -> String {
		return question!
	}
	
	func getAnswers() -> [String: Int] {
		return answers!
	}
	
	func didVote() -> Bool {
		return hasVoted
	}
	
	func setVote(vote : Bool) {
		self.hasVoted = vote
	}
	
	func setTitle(title : String) {
		self.question = title
	}
}

