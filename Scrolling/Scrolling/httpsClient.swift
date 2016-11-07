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
	
	init(token: String) {
		self.authToken = token
	}
	
	func getDemoPolls(done:@escaping ([Poll]) -> Void) {
		let header : HTTPHeaders = [
			"Authorization": authToken,
		]
		
		Alamofire.request("https://pollr-api.appspot.com/api/v1.0/demo", headers: header).responseJSON { response in
			
			if let result = response.result.value {
				let json = JSON(result)
				let jsonPolls = json["result"]
				
				var polls = [Poll]()
				
				for p in jsonPolls {
					
					let pollId = p.1["id"].intValue
					let question = p.1["question"].stringValue
					
					var responses = [String: Int]()
					for answer in p.1["answers"] {
						responses[answer.1["answer_text"].stringValue] = p.1["answer_count"].intValue
					}
					
					let newPoll = Poll(id: pollId, question: question, answers: responses)
					polls.append(newPoll)
				}
				
				done(polls)
			}
		}
	}
	
	func createPoll(question : String, answers : [String]) {
		
		let headers : HTTPHeaders = [
			"Authorization": authToken,
			"Content-Type": "application/json"
		]
		
		var answers_counts = [Int]()
		for i in 0..<answers.count {
			answers_counts.append(0)
		}
		
		let parameters : Parameters = [
			"question": question,
			"lat": 42.2808,
			"lon": -83.743,
			"radius": 1610,
			"answers": answers,
			"answer_counts": answers_counts
		]
		
		Alamofire.request("https://pollr-api.appspot.com/api/v1.0/polls", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
	}
	
	func getPoll(pollId: Int, done: @escaping (Poll) -> Void) {
		let header : HTTPHeaders = [
			"Authorization": authToken
			]
		
		Alamofire.request("https://pollr-api.appspot.com/api/v1.0/polls/" + String(pollId), headers: header).responseJSON { response in
			
			if let result = response.result.value {
				let json = JSON(result)
//				print("Json \(json)")
				let poll = json["result"]
			
				var responses = [String: Int]()
				for answer in poll["answers"] {
					responses[(answer.1["answer_text"].stringValue)] = answer.1["answer_count"].intValue
				}
				
				let pollId = poll["id"].intValue
				let question = poll["question"].stringValue
				
				let newPoll = Poll(id: pollId, question: question, answers: responses)
				
				print("Newly created poll: \(pollId), \(question), \(responses)")
				done(newPoll)
			}
		}
	}
	
	func voteOnPoll(pollId: Int, userVote: String) {
		
//		print("Vote on \(pollId) with answer \(responseIndex)")
		
		let headers : HTTPHeaders = [
			"Authorization": authToken,
			"Content-Type": "application/json"
		]
		
		let parameters : Parameters = [
			"answer_id": userVote
		]
		
		Alamofire.request("https://pollr-api.appspot.com/api/v1.0/polls/" + String(pollId), method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
			print(response.result.value)
		}
	}
}

