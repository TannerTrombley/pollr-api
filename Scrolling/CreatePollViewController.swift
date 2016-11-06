//
//  CreatePollViewController.swift
//  Scrolling
//
//  Created by David Hendershot on 10/30/16.
//  Copyright © 2016 Pollr. All rights reserved.
//

import UIKit
import Firebase

class CreatePollViewController: UIViewController, UITextFieldDelegate {

	// MARK: View Outlets
	@IBOutlet weak var questionText: UITextField!
	
	// Row of number of responses the user selects from
	@IBOutlet weak var numberReponseSelectionRow: UIStackView!
	
	// The stack the user's reponses are contained in
	@IBOutlet weak var responseStack: UIStackView!

	@IBOutlet weak var submitButton: UIButton!
	
	// MARK: Text Fields
	@IBOutlet weak var fourthResponse: UITextField!
	@IBOutlet weak var thirdResponse: UITextField!
	@IBOutlet weak var secondResponse: UITextField!
	@IBOutlet weak var firstResponse: UITextField!
	
	// MARK: Text View Delegate Methods
	func textFieldDidEndEditing(_ textField: UITextField) {
		print("event triggered")
		
		if questionText?.text == ""
			|| !((fourthResponse?.isHidden)!) && fourthResponse?.text == ""
			|| !((thirdResponse?.isHidden)!) && thirdResponse?.text == ""
			|| !((secondResponse?.isHidden)!) && secondResponse?.text == ""
			|| !((firstResponse?.isHidden)!) && firstResponse?.text == "" {
			
			print("One or more text fields are empty")
			submitButton.isUserInteractionEnabled = false
		} else {
			submitButton.isUserInteractionEnabled = true
		}
	}
	
	
	@IBAction func createDefeaultResponsePoll(_ sender: UIButton) {
		
	}
	
	@IBAction func customReponseClicked(_ sender: UIButton) {
		numberReponseSelectionRow.isHidden = false
	}
	
	@IBAction func userWantsTwoResponses(_ sender: UIButton) {
		revealReponseFields(first: true, second: true, third: false, fourth: false)
	}
	
	@IBAction func userWantsThreeResponses(_ sender: UIButton) {
		revealReponseFields(first: true, second: true, third: true, fourth: false)
	}
	
	@IBAction func userWantsFourResponses(_ sender: AnyObject) {
		revealReponseFields(first: true, second: true, third: true, fourth: true)
	}
	
	// Show which text fields the user wants
	func revealReponseFields(first: Bool, second: Bool, third: Bool, fourth: Bool) {
		
		if !first && !second && !third && !fourth {
			responseStack.isHidden = true
			submitButton.isHidden = true
		} else {
			responseStack.isHidden = false
			submitButton.isHidden = false
			submitButton.isUserInteractionEnabled = false
		}
		
		firstResponse?.isHidden = !first
		secondResponse?.isHidden = !second
		thirdResponse?.isHidden = !third
		fourthResponse?.isHidden = !fourth
	}
	
	
	@IBAction func submitPoll(_ sender: UIButton) {
		// validate user data
//		print("User's chosen repsonses:")
//		print("\(firstResponse.text)")
//		print("\(secondResponse.text)")
//		print("\(thirdResponse.text)")
//		print("\(fourthResponse.text)")

		var question = questionText.text
		var answers = [String]()
		
		if !((firstResponse?.isHidden)!) {
			answers.append(firstResponse.text!)
		}
		if !((secondResponse?.isHidden)!) {
			answers.append(secondResponse.text!)
		}
		if !((thirdResponse?.isHidden)!) {
			answers.append(thirdResponse.text!)
		}
		if !((fourthResponse?.isHidden)!) {
			answers.append(fourthResponse.text!)
		}
		
		let currentUser = FIRAuth.auth()?.currentUser
		currentUser?.getTokenForcingRefresh(true) {idToken, error in
			if let error = error {
				// Handle error
				return;
			}
			
			var client = clientAPI(token: idToken!)
			client.createPoll(question: question!, answers: answers)
		}
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		numberReponseSelectionRow.isHidden = true
		
		responseStack.isHidden = true
		submitButton.isHidden = true
		
		questionText.delegate = self
		firstResponse.delegate = self
		secondResponse.delegate = self
		thirdResponse.delegate = self
		fourthResponse.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
