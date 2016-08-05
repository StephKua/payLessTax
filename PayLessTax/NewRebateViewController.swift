//
//  NewRebateViewController.swift
//  PayLessTax
//
//  Created by Sheena Moh on 19/07/2016.
//  Copyright © 2016 SMoh. All rights reserved.
//

//
//  NewRebateViewController.swift
//  PayLessTax
//
//  Created by Sheena Moh on 19/07/2016.
//  Copyright © 2016 SMoh. All rights reserved.
//

import UIKit
import Firebase
import Fusuma

class NewRebateViewController: CameraViewController, UITextFieldDelegate {
    
    var selectedRebate: RebateCategories?
    var lastSubtotal = Double()
    
    var strDate: String = ""
    var datePicker = UIDatePicker()
    var imageUrl: String?
    
    @IBOutlet weak var rebateImage: UIImageView!
    @IBOutlet weak var categoryDetailsTextView: UITextView!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var receiptTextField: UITextField!
    
    @IBOutlet weak var scrollView: UIScrollView!
    var activeTextField: UITextField?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = selectedRebate!.title
        datePicker = UIDatePicker(frame: CGRectMake(10, 10, view.frame.width, 200))
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        strDate = dateFormatter.stringFromDate(datePicker.date)
        dateTextField.text = strDate
        
        let rebateCategoryRef = firebaseRef.child("RebateCategories").child(selectedRebate!.title).child("catDesc")
        rebateCategoryRef.observeEventType(.Value, withBlock:  { (snapshot) in
            if let description = snapshot.value as? String {
                let text = description
                self.categoryDetailsTextView.text = text
            }
        })
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SignUpViewController.registerForKeyboardNotifications), name:UIKeyboardWillShowNotification, object: self.view.window)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SignUpViewController.registerForKeyboardNotifications), name: UIKeyboardWillHideNotification, object: self.view.window)
        
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        activeTextField = textField
        
        let inputView = UIView(frame: CGRectMake(0, 200, view.frame.width, 200))
        inputView.backgroundColor = UIColor.whiteColor()
        
        datePicker.datePickerMode = UIDatePickerMode.Date
        inputView.addSubview(datePicker)
        
        datePicker.addTarget(self, action: #selector(NewRebateViewController.donePicker), forControlEvents: UIControlEvents.TouchUpInside)
        
        let toolbar = UIToolbar()
        toolbar.barStyle = UIBarStyle.Default
        toolbar.translucent = true
        toolbar.tintColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1)
        toolbar.sizeToFit()
        
        let doneBarBtn = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action: #selector(NewRebateViewController.donePicker))
        let spaceBarBtn = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        let cancelBarBtn = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(NewRebateViewController.cancelPicker))
        
        toolbar.setItems([cancelBarBtn, spaceBarBtn, doneBarBtn], animated: false)
        toolbar.userInteractionEnabled = true
        
        dateTextField.inputView = inputView
        dateTextField.inputAccessoryView = toolbar
        
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        activeTextField = nil
    }
    
    func donePicker() {
        dateTextField.resignFirstResponder()
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        strDate = dateFormatter.stringFromDate(datePicker.date)
        
        self.dateTextField.text = strDate
    }
    
    func cancelPicker() {
        dateTextField.resignFirstResponder()
    }
    
    @IBAction func onSaveBtnPressed(sender: UIBarButtonItem) {
        
        if amountTextField.text == "" || receiptTextField.text == "" {
            self.resignFirstResponder()
            let alertController = UIAlertController(title: "Missing Info", message: "Please enter both the receipt number and receipt amount", preferredStyle: .Alert)
            let dismissAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alertController.addAction(dismissAction)
            self.presentViewController(alertController, animated: true, completion: nil)
//        } else if Validation.isStringNumerical(amountTextField.text!) == false {
//            let alertController = UIAlertController(title: "Invalid amount", message: "Please enter a valid amount", preferredStyle: .Alert)
//            let dismissAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
//            alertController.addAction(dismissAction)
//            self.presentViewController(alertController, animated: true, completion: nil)
        } else {
            self.resignFirstResponder()
            self.addRebate()
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    @IBAction func cameraButtonPressed(sender: UIButton) {
        self.presentViewController(fusuma, animated: true, completion: nil)
    }
    
    func addRebate() {
        guard let date = dateTextField.text, let receiptNo = receiptTextField.text, let amount = amountTextField.text else { return }
        
        var amountAdded = Double()
        if amount != "" {
            amountAdded = Double(amount)!
        }
        
        let imageUrl = self.imageUrl ?? ""
        
        let receiptID = NSUUID().UUIDString
        let imageID = NSUUID().UUIDString
        
        let receiptRef = firebaseRef.child("receipt").child(receiptID)
        let receiptDict = ["date": date, "receipt no": receiptNo, "amount": amountAdded, "category": selectedRebate!.title]
        receiptRef.setValue(receiptDict)
        
        let imageRef = firebaseRef.child("image").child(imageID)
        let imageDict = ["imageUrl": imageUrl, "userID": User.currentUserId()!]
        imageRef.setValue(imageDict)
        
        let rebateRef = firebaseRef.child("rebate").child(User.currentUserId()!).child(selectedRebate!.title)
        rebateRef.child("receiptID").child(receiptID).setValue(true)
        rebateRef.child("imageID").child(imageID).setValue(true)
        
        var newTotal = Double()
        let rebateCatRef = firebaseRef.child("RebateCategories").child(self.selectedRebate!.title).child("subtotal")
        
        rebateRef.observeSingleEventOfType(.Value, withBlock:  { (snapshot) in
            if var rebateTypeDict = snapshot.value as? [String: AnyObject] {
                if let oldValue = rebateTypeDict["subtotal"] as? Double {
                    rebateTypeDict["subtotal"] = oldValue + amountAdded
                    newTotal = oldValue + amountAdded
                } else {
                    rebateTypeDict["subtotal"] = amountAdded
                    newTotal = amountAdded
                }
                rebateCatRef.child(User.currentUserId()!).setValue(newTotal)
                rebateRef.updateChildValues(rebateTypeDict)
            }
        })
        
    }
    
    func registerForKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWasShown), name: UIKeyboardWillShowNotification, object: nil)
    }
    
    func keyboardWasShown(notification: NSNotification) {
        let info = notification.userInfo!
        let kbSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue().size
        
        let contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize!.height, 0.0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
        
        var rect = self.view.frame
        rect.size.height -= kbSize!.height
        
        if let activeField = activeTextField {
            if CGRectContainsPoint(rect, activeTextField!.frame.origin) {
                self.scrollView.scrollRectToVisible(activeField.frame, animated: true)
                
            }
        }
    }
    
    override func imageUploadCompleted(imageURL: String, image: UIImage) {
        let rect = CGRectMake(0, 0, 100, 100)
        rebateImage.image = image
        rebateImage.image!.drawInRect(rect)
        self.imageUrl = imageURL
        
    }
    
    override func setInfo(total: String, date: String, InvNo: String) {
        self.amountTextField.text = total
        self.dateTextField.text = date
        self.receiptTextField.text = InvNo
    }
    
}




