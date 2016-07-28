//
//  ViewController.swift
//  PayLessTax
//
//  Created by Sheena Moh on 18/07/2016.
//  Copyright © 2016 SMoh. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var scrollView: UIScrollView!
    var activeTextField:UITextField?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTapped()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.registerForKeyboardNotifications()
    }
    
    
    func registerForKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWasShown), name: UIKeyboardWillShowNotification, object: nil)
    }
    
    func keyboardWasShown(notification: NSNotification) {
        let info = notification.userInfo!    //userinfo tells u info incl keyboard size (info tat notification sends)
        let kbSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue().size    //obtain keyboard frame N size
        
        let contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize!.height, 0.0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
        
        var rect = self.view.frame //getting frame of whole view
        rect.size.height -= kbSize!.height
        
        if let activeField = activeTextField {
            if CGRectContainsPoint(rect, activeTextField!.frame.origin) {
                self.scrollView.scrollRectToVisible(activeField.frame, animated: true)
                
            }
        }
    }
    
//    - (void)keyboardWasShown:(NSNotification*)aNotification {
//    NSDictionary* info = [aNotification userInfo];
//    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
//    CGRect bkgndRect = activeField.superview.frame;
//    bkgndRect.size.height += kbSize.height;
//    [activeField.superview setFrame:bkgndRect];
//    [scrollView setContentOffset:CGPointMake(0.0, activeField.frame.origin.y-kbSize.height) animated:YES];
//    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        activeTextField = textField
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        activeTextField = nil
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

