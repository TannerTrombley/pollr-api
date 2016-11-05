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
	var answers: [String]?
	
	init(id: Int, question: String, answers: [String]) {
		self.id = id
		self.question = question
		self.answers = answers
	}
	
	func getId() -> Int {
		return id!
	}
	
	func getQuestion() -> String {
		return question!
	}
	
	func getAnswers() -> [String] {
		return answers!
	}
}

class Simple {
	var id : Int?
	var question : String?
	var answers : [String]?
	
	init(first: Int, second: String, third: [String]) {
		id = first
		question = second
		answers = third
	}
}

