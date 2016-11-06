//
//  LoginScreen.swift
//  Scrolling
//
//  Created by David Hendershot on 11/5/16.
//  Copyright © 2016 Pollr. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FirebaseAuth

class LoginScreen: UIViewController, FBSDKLoginButtonDelegate {

	let loginButton = FBSDKLoginButton()
	
    override func viewDidLoad() {
        super.viewDidLoad()

		// Optional: Place the button in the center of your view.
		self.loginButton.center = self.view.center
		self.loginButton.readPermissions = ["public_profile", "email", "user_friends"]
		self.loginButton.delegate = self
		self.view!.addSubview(loginButton)
    }

	func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
		
		if error != nil {
			print(error)
			return
		}
		
		let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
		
		FIRAuth.auth()?.signIn(with: credential) { (user, error) in
			print("Access token \(FBSDKAccessToken.current().tokenString)")
			print("User: \(user)")
			print("The user is: \(user?.displayName)")
			
//			let vc = MainViewController()
//			self.present(vc, animated: true, completion: nil)
		}
	}

	func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
		print("User logged out")
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
