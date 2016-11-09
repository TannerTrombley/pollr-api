//
//  CreationViewController.swift
//  Scrolling
//
//  Created by David Hendershot on 11/9/16.
//  Copyright © 2016 Pollr. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class CreationViewController: UIViewController, UITextFieldDelegate, MKMapViewDelegate, CLLocationManagerDelegate
{

	// MARK: Outlets
	@IBOutlet weak var questionView: UIView!
	@IBOutlet weak var questionText: UITextField!
	
	
	@IBOutlet weak var responseView: UIView!
	@IBOutlet weak var firstAnswerField: UITextField!
	@IBOutlet weak var secondAnswerField: UITextField!
	@IBOutlet weak var thirdAnswerField: UITextField!
	@IBOutlet weak var fourthAnswerField: UITextField!
	

	@IBOutlet weak var locationView: UIView!
	@IBOutlet weak var mapView: MKMapView!

	
	@IBOutlet weak var submissionView: UIView!
	
	
	
	// MARK: Member Variables
	let locationManager = CLLocationManager()
	
	
	
    override func viewDidLoad() {
        super.viewDidLoad()
	
		// Question View Setup
		self.questionText.delegate = self
		self.questionText.tag = 1
		
		// Response View Setup
		self.responseView.alpha = 0.0
		
		self.firstAnswerField.delegate = self
		self.firstAnswerField.tag = 2
		
		self.secondAnswerField.delegate = self
		self.secondAnswerField.tag = 3
		
		// Location View Setup
		self.locationView.alpha = 0.0
		
		self.locationManager.delegate = self
		self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
		self.locationManager.requestWhenInUseAuthorization()
		self.locationManager.startUpdatingLocation()
		self.mapView.showsUserLocation = true
		
		// Submission View Setup
		self.submissionView.alpha = 0.0
    }
	
	
	// MARK: Location Delegate Methods
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		
		// Get the most recent location
		let location = locations.last
		
		// Get the 'center' of that location
		let center = CLLocationCoordinate2D(latitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!)
		
		// Create a region that the map will zoom too
		let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1))
		
		self.mapView.setRegion(region, animated: true)
		self.locationManager.stopUpdatingLocation()
	}
	
	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		print("Errors: \(error.localizedDescription)")
	}
	
	
	
	
	// MARK: Text Field Handling
	
	func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
		print("asking if we should stop editing?")
		return textField.text != ""
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		
		switch textField.tag {
			case 1:
				print("The question text is done editing")
				if textField.text != "" {
					self.questionText.resignFirstResponder()
					return true
				}
				return false
			case 2, 3:
				print("Typing in a response")
				if (firstAnswerField.text != "") && (secondAnswerField.text != "") {
					print("At least the first two are non-empty so animate")
					UIView.animate(withDuration: 0.5, animations: {
						self.locationView.alpha = 1.0
						self.submissionView.alpha = 1.0
					})
					return true
				}
				return false
			default:
				break
		}
		return false
	}
	
	
	func textFieldDidEndEditing(_ textField: UITextField) {
		
		print("The user stopped typing")
		
		if textField.text != "" {
			UIView.animate(withDuration: 0.5, animations: {
				self.responseView.alpha = 1.0
			})
		}
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
