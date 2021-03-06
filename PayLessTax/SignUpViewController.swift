//
//  SignUpViewController.swift
//  PayLessTax
//
//  Created by Sheena Moh on 19/07/2016.
//  Copyright © 2016 SMoh. All rights reserved.
//

import UIKit
import Firebase

class SignUpViewController: ReusableKeyboardViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var incomeTaxNoTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    var firebaseRef = FIRDatabase.database().reference()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTapped()
    }

    
    @IBAction func onSignUpBtnClicked(sender: UIButton) {
        guard let username = usernameTextField.text, let email = emailTextField.text, let password = passwordTextField.text, let incomeTaxNo = incomeTaxNoTextField.text else { return }
        
        FIRAuth.auth()?.createUserWithEmail(email, password: password, completion: { (user, error) in
            if let user = user {
                let userDict = ["email": email, "username": username, "incomeTaxNo": incomeTaxNo]
                self.firebaseRef.child("users").child(user.uid).setValue(userDict)
                NSUserDefaults.standardUserDefaults().setValue(user.uid, forKey: "uid")
                User.signIn(user.uid)
                self.performSegueWithIdentifier("LoginSegue", sender: sender)
                
            } else {
                let controller = UIAlertController(title: "Error", message: (error?.localizedDescription), preferredStyle: .Alert)
                let dismissBtn = UIAlertAction(title: "Try Again", style: .Default, handler: nil)
                controller.addAction(dismissBtn)
                
                self.presentViewController(controller, animated: true, completion: nil)
            }
        })
    }
    
}
