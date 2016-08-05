//
//  SignUpViewController.swift
//  PayLessTax
//
//  Created by Sheena Moh on 19/07/2016.
//  Copyright © 2016 SMoh. All rights reserved.
//

import UIKit
import Firebase

class ReusableKeyboardViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    var activeTextField: UITextField?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTapped()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SignUpViewController.registerForKeyboardNotifications), name:UIKeyboardWillShowNotification, object: self.view.window)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SignUpViewController.registerForKeyboardNotifications), name: UIKeyboardWillHideNotification, object: self.view.window)
        
    }
    
    func registerForKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWasShown), name: UIKeyboardWillShowNotification, object: nil)
    }
    
    func keyboardWasShown(notification: NSNotification) {
        let info = notification.userInfo!    //userinfo tells u info incl keyboard size (info tat notification sends)
        let kbSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue().size    //obtain keyboard frame N size
        
        let contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize!.height, 0.0)
        scrollView.contentInset = contentInsets //need too add iboutlet
        scrollView.scrollIndicatorInsets = contentInsets
        
        var rect = self.view.frame //getting frame of whole view
        rect.size.height -= kbSize!.height
        
        if let activeField = activeTextField {
            if CGRectContainsPoint(rect, activeTextField!.frame.origin) {
                self.scrollView.scrollRectToVisible(activeField.frame, animated: true)
                
            }
        }
    }
    
    
    func textFieldDidBeginEditing(textField: UITextField) {
        activeTextField = textField
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        activeTextField = nil
    }
    
    
    
}

extension UIViewController {
    
    //MARK: Hide keyboard when tapped
    
    func hideKeyboardWhenTapped() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard()  {
        view.endEditing(true)
    }

}
