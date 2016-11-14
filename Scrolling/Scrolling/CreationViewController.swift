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

import Firebase

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
		
		self.thirdAnswerField.delegate = self
		self.thirdAnswerField.tag = 4
		
		self.fourthAnswerField.delegate = self
		self.fourthAnswerField.tag = 5
		
		// Location View Setup
		self.locationView.alpha = 0.0
		self.mapView.delegate = self
		
		self.locationManager.delegate = self
		self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
		self.locationManager.requestWhenInUseAuthorization()
		self.locationManager.startUpdatingLocation()
		self.mapView.showsUserLocation = true
		
		let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress))
		lpgr.minimumPressDuration = 1.0
		self.mapView.addGestureRecognizer(lpgr)
		
		// Submission View Setup
		self.submissionView.alpha = 0.0
		self.submissionView.layer.cornerRadius = 10.0
		self.submissionView.layer.shadowColor = UIColor.black.cgColor
		self.submissionView.layer.shadowRadius = 5.0
		self.submissionView.clipsToBounds = false
		
	
		// Navigation Bar
		if let navBar = self.navigationController?.navigationBar {
//			navBar.tintColor = UIColor(red: CGFloat(230), green: CGFloat(230), blue: CGFloat(250), alpha: 1.0)
			navBar.barTintColor = UIColor(red: CGFloat(230), green: CGFloat(230), blue: CGFloat(250), alpha: CGFloat(1.0))
//			navBar.barTintColor = UIColor.green
		}
	
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
	
	
	// MARK: Map Delegation Methods
	func handleLongPress(_ gestureRecognizer: UIGestureRecognizer) {
		if gestureRecognizer.state != .began {
			return
		}
		
		// Remove any existing pins
		if !mapView.annotations.isEmpty {
			mapView.removeAnnotations(mapView.annotations)
		}
		
		let touchPoint = gestureRecognizer.location(in: self.mapView)
		let touchMapCoordinate = self.mapView.convert(touchPoint, toCoordinateFrom: self.mapView)
		let annot = MKPointAnnotation()
		annot.coordinate = touchMapCoordinate
		self.mapView.addAnnotation(annot)
	}
	
	// Animates the annotation
//	func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//		print("It's a animatin")
//		
//		if let pin = annotation as? MKPinAnnotationView {
//			print("It's a pin")
//			pin.animatesDrop = true
//			return pin
//		}
//		print("Return a generic annotation view")
//		return MKAnnotationView()
//	}
	
	
	
	
	// MARK: Text Field Handling
	func textFieldDidEndEditing(_ textField: UITextField) {

		if textField.text != "" {
			textField.resignFirstResponder()
			UIView.animate(withDuration: 0.5, animations: {
				self.responseView.alpha = 1.0
			})
		}
	}

	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true
	}
	
	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		
		if (firstAnswerField.text != "") && (secondAnswerField.text != "") {

			UIView.animate(withDuration: 0.5, animations: {
				self.locationView.alpha = 1.0
				self.submissionView.alpha = 1.0
			})
		}
		return true
	}
	
	
	
	// MARK: Validate input and send to server
	
	@IBAction func submitPoll(_ sender: UIButton) {
		let lastAnnotation = self.mapView.annotations.last
		let lastCoordinate = lastAnnotation?.coordinate
		
		print("The poll will be placed at \(lastCoordinate?.latitude), \(lastCoordinate?.longitude)")
		
		if questionText.text != "" && atLeastTwoResponsesPopualted() && locationPicked() {
			print("Allow submission")
			
			let question = questionText.text
			
			var answers = [String]()
			let fields = [self.firstAnswerField, self.secondAnswerField, self.thirdAnswerField, self.fourthAnswerField]
			
			for field in fields {
				if field?.text != "" {
					answers.append((field?.text)!)
				}
			}
		
			let currentUser = FIRAuth.auth()?.currentUser
			currentUser?.getTokenForcingRefresh(true) {idToken, error in
				if let error = error {
					print("Error: \(error)")
					return;
				}
				
				let client = clientAPI(token: idToken!)
				client.createPoll(question: question!, answers: answers, latitude: (lastCoordinate?.latitude)!, longitude: (lastCoordinate?.longitude)!)
				
				self.clearSelf()
				self.goHome(sender: self)
			}
			
		}
		
		
	}
	
	func clearSelf() {

		self.questionText.text = ""
		
		self.firstAnswerField.text = ""
		self.secondAnswerField.text = ""
		self.thirdAnswerField.text = ""
		self.fourthAnswerField.text = ""
		
		self.mapView.removeAnnotations(self.mapView.annotations)
		
		self.responseView.alpha = 0.0
		self.locationView.alpha = 0.0
		self.submissionView.alpha = 0.0

	}
	
	func goHome(sender: AnyObject) {
		tabBarController?.selectedIndex = 1
	}
	
	
	
	func atLeastTwoResponsesPopualted() -> Bool {
		let responses = [self.firstAnswerField, self.secondAnswerField, self.thirdAnswerField, self.fourthAnswerField]
		
		func isNonEmpty(textField : UITextField?) -> Bool {
			return !((textField?.text?.isEmpty)!)
		}
		
		return responses.filter(isNonEmpty).count >= 2
	}
	
	
	func locationPicked() -> Bool {
		return self.mapView.annotations.count > 1
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
