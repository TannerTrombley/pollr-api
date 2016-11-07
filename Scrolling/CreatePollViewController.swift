//
//  CreatePollViewController.swift
//  Scrolling
//
//  Created by David Hendershot on 10/30/16.
//  Copyright © 2016 Pollr. All rights reserved.
//

import UIKit
import MapKit
import Firebase

class CreatePollViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

	// MARK: View Outlets
	@IBOutlet weak var questionText: UITextField!
	
	// Row of number of responses the user selects from
	@IBOutlet weak var numberReponseSelectionRow: UIStackView!
	
	@IBOutlet weak var pickerView: UIPickerView!
	var pickerData = [String]()
	
	// The stack the user's reponses are contained in
	@IBOutlet weak var responseStack: UIStackView!

	// Call the Map View with the currently selected city's location
	@IBAction func checkLocation(_ sender: UIButton) {
		let cities = [[42.2808, -83.7430, 0.1],
		              [10.4806, -66.9036, 0.1],
		              [43.6157, -84.2472, 3.0],
		              [40.7128, -74.0059, 0.1],
		              [37.4419, -122.1430, 0.1],
		              [37.0902,-95.7129, 25.0]]
		
		//Get the picker's city
		let location = cities[pickerView.selectedRow(inComponent: 0)]
		
		pinMap(pinLatitude: location[0] as! Double, pinLongitude: location[1] as! Double, radius: MKCoordinateSpanMake(location[2], location[2]))
	}
	
//	func centerMapOnLocation(location: CLLocation) {
//		let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
//		LocationMap.setRegion(coordinateRegion, animated: true)
//	}
	
	
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
	
	// Redirects to the map and places a pin in it
	func pinMap(pinLatitude: Double, pinLongitude: Double, radius: MKCoordinateSpan){
		
		let coordinate = CLLocationCoordinate2DMake(pinLatitude, pinLongitude)
		let region = MKCoordinateRegionMake(coordinate, radius)
		let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: nil)
		let mapItem = MKMapItem(placemark: placemark)
		let options = [
			MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: region.center),
			MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: region.span)
		]
		//mapItem.name = theLocationName
		mapItem.openInMaps(launchOptions: options)
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
		
		self.pickerView.delegate = self
		self.pickerView.dataSource = self
		
		pickerData = ["Ann Arbor", "Caracas", "Michigan", "New York City", "Palo Alto", "USA"]
    }

	public func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return 1
	}
	
	public func pickerView(_ pickerView: UIPickerView,
	                       numberOfRowsInComponent component: Int) -> Int {
		return pickerData.count
	}
	
	public func pickerView(_ pickerView: UIPickerView,
	                       titleForRow row: Int,
	                       forComponent component: Int) -> String? {
		return pickerData[row]
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
