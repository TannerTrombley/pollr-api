//
//  httpsClient.swift
//  Scrolling
//
//  Created by David Hendershot on 11/4/16.
//  Copyright © 2016 Pollr. All rights reserved.
//

import Alamofire
import SwiftyJSON

class clientAPI {
	var authToken = "eyJhbGciOiJSUzI1NiIsImtpZCI6ImQyYzI5OTZhMjFjZDAzZmNlNjdlODVhZjk1MjVmNDBjNzIzZmFhMTYifQ.eyJpc3MiOiJodHRwczovL3NlY3VyZXRva2VuLmdvb2dsZS5jb20vcG9sbHItYXBpIiwibmFtZSI6IkRhdmlkIEhlbmRlcnNob3QiLCJwaWN0dXJlIjoiaHR0cHM6Ly9zY29udGVudC54eC5mYmNkbi5uZXQvdi90MS4wLTEvcDEwMHgxMDAvMTIxMTE5MjNfMTAyMDgyNjQ3OTEyODQzODRfNTkzNDUwNTQ3NjQ3NjI0NjIyM19uLmpwZz9vaD02NzZhZjRmYjE5OGYzYmY3YmE3MTRkNzRjYzk1MGFkOSZvZT01ODlCMkY4QyIsImF1ZCI6InBvbGxyLWFwaSIsImF1dGhfdGltZSI6MTQ3ODM1Nzc4OSwidXNlcl9pZCI6IkZGYjN5VndsTkhQYmYwZmhwMjJmV3BpQ0U1aDEiLCJzdWIiOiJGRmIzeVZ3bE5IUGJmMGZocDIyZldwaUNFNWgxIiwiaWF0IjoxNDc4MzU3Nzg5LCJleHAiOjE0NzgzNjEzODksImVtYWlsIjoiZGF2aWRoZW5kZXJzaG90MjAxMkBnbWFpbC5jb20iLCJlbWFpbF92ZXJpZmllZCI6ZmFsc2UsImZpcmViYXNlIjp7ImlkZW50aXRpZXMiOnsiZmFjZWJvb2suY29tIjpbIjEwMjExMTA1MjkxOTc1MTI2Il0sImVtYWlsIjpbImRhdmlkaGVuZGVyc2hvdDIwMTJAZ21haWwuY29tIl19LCJzaWduX2luX3Byb3ZpZGVyIjoiZmFjZWJvb2suY29tIn19.iqSuWrAQGUPLB0jid41Kbt2BL9wBSZT6KbBX7frpGNVUcsBThRPzKWnI6jE601Pxh4jerONFLesmLnm8BlLYc8ArUOgVAYFWW14laBo-2HYMYxiGNHy3Q7X64Tr1MD_oe7DMCD3VYBPpq898er7tJirLkn838e-MPAVWlOc8sM95b0Emr4PWHowHmgRFVGgvQX5jWIQVf6hhJqhMKn1eWz33XCLXa2b_wFtoqirmVjmgNCle-6RlSKrf6FbHpkTIxy4xpYFgzX-2LiOQVL0wUJndPTG-P5WKEZ5KBs2d9Gy8i53f_fBkvOgb3ydXHRpM9YN1DhNZYuD-tdA18AhxrA"
	
	func getDemoPolls(done:@escaping ([Poll]) -> Void) {
		let header : HTTPHeaders = [
			"Authorization": authToken,
		]
		
		Alamofire.request("https://pollr-api.appspot.com/api/v1.0/demo", headers: header).responseJSON { response in
			
//			var polls = [Poll(id: 1,
//			                  question: "What's your relationship with hunting?",
//			                  answers: ["Semi-serious", "On and off", "Exclusive", "Open"])]
			
			if let result = response.result.value {
				let json = JSON(result)
				let jsonPolls = json["result"]
				
				var polls = [Poll]()
				
				for p in jsonPolls {
					
					var responses = [String]()
					for answer in p.1["answers"] {
						responses.append(answer.1["answer_text"].stringValue)
					}
					
					let pollId = p.1["id"].intValue
					let question = p.1["question"].stringValue
					
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
		
		Alamofire.request("https://pollr-api.appspot.com/api/v1.0/demo", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
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
			
				var responses = [String]()
				for answer in poll["answers"] {
					responses.append(answer.1["answer_text"].stringValue)
				}
				
				let pollId = poll["id"].intValue
				let question = poll["question"].stringValue
				
				let newPoll = Poll(id: pollId, question: question, answers: responses)
				
				print("Newly created poll: \(pollId), \(question), \(responses)")
//				done(newPoll)
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

