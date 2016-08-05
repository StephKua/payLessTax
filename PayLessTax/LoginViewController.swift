//
//  ViewController.swift
//  PayLessTax
//
//  Created by Sheena Moh on 18/07/2016.
//  Copyright © 2016 SMoh. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: ReusableKeyboardViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTapped()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.registerForKeyboardNotifications()
    }
     
    @IBAction func onLoginBtnClicked(sender: UIButton) {
        guard let email = emailTextField.text, let password = passwordTextField.text else { return }
        
        FIRAuth.auth()?.signInWithEmail(email, password: password, completion: { (user, error) in
            if let user = user {
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
    
    
    @IBAction func backToLogin (segue: UIStoryboardSegue) {
        
    }
    
}

