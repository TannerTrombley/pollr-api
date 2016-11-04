//
//  CreatePollViewController.swift
//  Scrolling
//
//  Created by David Hendershot on 10/30/16.
//  Copyright © 2016 Pollr. All rights reserved.
//

import UIKit

class CreatePollViewController: UIViewController {

	@IBOutlet weak var questionText: UITextField!
	
	// Row of number of responses the user selects from
	@IBOutlet weak var numberReponseSelectionRow: UIStackView!
	
	// The stack the user's reponses are contained in
	@IBOutlet weak var responseStack: UIStackView!

	// The response text fields
	@IBOutlet weak var fourthResponse: UITextField!
	@IBOutlet weak var thirdResponse: UITextField!
	@IBOutlet weak var secondResponse: UITextField!
	@IBOutlet weak var firstResponse: UITextField!
	
	@IBOutlet weak var submitButton: UIButton!
	
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
		}
		
		firstResponse?.isHidden = !first
		secondResponse?.isHidden = !second
		thirdResponse?.isHidden = !third
		fourthResponse?.isHidden = !fourth
	}
	
	
	@IBAction func submitPoll(_ sender: UIButton) {
		// validate user data
		print("User's chosen repsonses:")
		print("\(firstResponse.text)")
		print("\(secondResponse.text)")
		print("\(thirdResponse.text)")
		print("\(fourthResponse.text)")
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		numberReponseSelectionRow.isHidden = true
		
		responseStack.isHidden = true
		submitButton.isHidden = true
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
