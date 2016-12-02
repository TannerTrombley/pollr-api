//
//  httpsClient.swift
//  Scrolling
//
//  Created by David Hendershot on 11/4/16.
//  Copyright © 2016 Pollr. All rights reserved.
//

import Alamofire
import SwiftyJSON
import FBSDKLoginKit
import Firebase


class clientAPI {
	var authToken : String
	
	// Only constructor requires a Firebase authorization token
	init(token: String) {
		self.authToken = token
	}
	

	
	// MARK: GET requests
	
	// Retrieve spoofed polls for demonstration purposes
	func getDemoPolls(done:@escaping ([Poll]) -> Void) {
		let header : HTTPHeaders = [
			"Authorization": authToken,
		]
		
		Alamofire.request("https://pollr-api.appspot.com/api/v1.0/demo", headers: header).responseJSON { response in
			if let result = response.result.value {
				let polls = self.parsePolls(serverResponse: JSON(result))
				done(polls)
			}
		}
	}
	
	// Parses the JSON and returns a list of the found Polls
	func parsePolls(serverResponse: JSON) -> [Poll] {
		
		let pollData = serverResponse["result"]
		var polls = [Poll]()
		
		for p in pollData {
			
			let pollId = p.1["id"].intValue
			let question = p.1["question"].stringValue
			let voted = p.1["voted"].boolValue
			
			var responses = [String: Int]()
			for answer in p.1["answers"] {
				responses[answer.1["answer_text"].stringValue] = p.1["answers_count"].intValue
			}
			
			let newPoll = Poll(id: pollId, question: question, answers: responses, voted: voted)
			polls.append(newPoll)
		}
		
		return polls
	}
	
	// Retrieve the polls a particular user has created
	func getMyPolls(done:@escaping ([Poll]) -> Void) {
		let header : HTTPHeaders = [
			"Authorization": authToken,
			]
		
		Alamofire.request("https://pollr-api.appspot.com/api/v1.0/user/polls", headers: header).responseJSON { response in
			if let result = response.result.value {
				let polls = self.parsePolls(serverResponse: JSON(result))
				done(polls)
			}
		}
	}
	
	// Retrieve all polls within a certain radius of the user's current location
	func getPolls(latitude: Double, longitude: Double, done:@escaping ([Poll]) -> Void) {
		let header : HTTPHeaders = [
			"Authorization": authToken,
			]
		
		let parameters : Parameters = [
			"lat": latitude,
			"lon": -longitude
		]
		
		Alamofire.request("https://pollr-api.appspot.com/api/v1.0/location/polls", parameters: parameters, headers: header).responseJSON { response in
			
			if let result = response.result.value {
				let polls = self.parsePolls(serverResponse: JSON(result))
				done(polls)
			}
		}
	}
	
	// Retrieve a particular poll for further analysis
	func getPoll(pollId: Int, done: @escaping (Poll, [String]) -> Void) {
		let header : HTTPHeaders = [
			"Authorization": authToken
			]
		
		Alamofire.request("https://pollr-api.appspot.com/api/v1.0/polls/" + String(pollId), headers: header).responseJSON { response in
			if let result = response.result.value {
				let poll = self.parsePoll(serverResponse: JSON(result))
				let comments = self.parseComments(serverResponse: JSON(result))
				done(poll, comments)
			}
		}
	}
	
	func parsePoll(serverResponse: JSON) -> Poll {
		let pollData = serverResponse["result"]

		let question = pollData["question"].stringValue
		
		var responses = [String: Int]()
		for answer in pollData["answers"] {
			responses[answer.1["answer_text"].stringValue] = answer.1["count"].intValue
		}
		
		let newPoll = Poll(id: 0, question: question, answers: responses, voted: true)
		return newPoll
	}
	
	func parseComments(serverResponse: JSON) -> [String] {
		var comments = [String]()
		
		let commentData = serverResponse["result"]["comments"]
		for comment in commentData {
			comments.append(comment.1["comment_text"].stringValue)
		}

		return comments
	}
	
	// Retrieve the user's points
	func getPoints(done: @escaping (Int) -> Void) {
		
		let headers : HTTPHeaders = [
			"Authorization": authToken,
			]
		
		Alamofire.request("https://pollr-api.appspot.com/api/v1.0/user", method: .get, headers: headers).responseJSON { response in
			if let result = response.result.value {
				let json = JSON(result)
				let points = json["result"]["user_points"].intValue
				done(points)
			}
		}
	}
	
	
	// MARK: POST requests
	
	// Create a poll with the given particulars
	func createPoll(question : String, answers : [String], latitude: Double, longitude: Double) {
		
		let headers : HTTPHeaders = [
			"Authorization": authToken,
			"Content-Type": "application/json"
		]
		
		let answer_counts = [Int](repeating: 0, count: answers.count)
		
		let parameters : Parameters = [
			"question": question,
			"lat": latitude,
			"lon": longitude,
			"radius": 8000,
			"answers": answers,
			"answer_counts": answer_counts
		]
		
		Alamofire.request("https://pollr-api.appspot.com/api/v1.0/polls", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
	}
	
	// Place a single vote for the specified answer on the specified poll
	func voteOnPoll(pollId: Int, userVote: String) {
		
		let headers : HTTPHeaders = [
			"Authorization": authToken,
			"Content-Type": "application/json"
		]
		
		let parameters : Parameters = [
			"answer_id": userVote
		]
		
		Alamofire.request("https://pollr-api.appspot.com/api/v1.0/polls/" + String(pollId), method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
		}
	}
	
	
	func submitComment(pollId: Int, userComment: String) {
		let headers : HTTPHeaders = [
			"Authorization": authToken,
			"Content-Type": "application/json"
		]
		
		let parameters : Parameters = [
			"text": userComment
		]
		
		Alamofire.request("https://pollr-api.appspot.com/api/v1.0/comment/" + String(pollId), method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
		}
	}
}

