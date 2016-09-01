//
//  EditRebateViewController.swift
//  PayLessTax
//
//  Created by Sheena Moh on 26/07/2016.
//  Copyright © 2016 SMoh. All rights reserved.
//

import UIKit
import Firebase

class EditRebateViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var rebateTypeTextField: UITextField!
    @IBOutlet weak var receiptNoTextField: UITextField!
    @IBOutlet weak var amountTextField: UITextField!
    var rebReceipt: Receipt?
    
    var strDate: String = ""
    var datePicker = UIDatePicker()
    
    @IBOutlet weak var rebateImageView: UIImageView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    var activeTextField: UITextField?
    
    var edit = false
    var firebaseRef = FIRDatabase.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTapped()

        guard let title = rebReceipt?.category, let date = rebReceipt?.date, let rebateType = rebReceipt?.category, let receiptNo = rebReceipt?.receiptNo, let amount = rebReceipt?.amount else { return }
        
        self.disableEdit()
        getImage()
        self.title = title
        self.dateTextField.text = date
        self.rebateTypeTextField.text = rebateType
        self.receiptNoTextField.text = receiptNo
        self.amountTextField.text = "\(amount.asCurrency)"
        
        datePicker = UIDatePicker(frame: CGRectMake(10, 10, view.frame.width, 200))
    }
    
    
    @IBAction func onEditBtnPressed(sender: UIButton) {
        if edit == true {
            let amount = amountTextField.text?.formattedNo
            
            if amountTextField.text == "" || amount?.isValidNumber == false {
                self.resignFirstResponder()
                let alertController = UIAlertController(title: "Invalid amount", message: "Please enter a valid amount", preferredStyle: .Alert)
                let dismissAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                alertController.addAction(dismissAction)
                self.presentViewController(alertController, animated: true, completion: nil)
            } else if self.receiptNoTextField.text == "" {
                self.resignFirstResponder()
                let alertController = UIAlertController(title: "Missing Receipt Number", message: "Please enter valid receipt number", preferredStyle: .Alert)
                let dismissAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                alertController.addAction(dismissAction)
                self.presentViewController(alertController, animated: true, completion: nil)
            } else {
                self.disableEdit()
                sender.setTitle("Edit", forState: UIControlState.Normal)
                self.edit = false
                self.updateRebate()
            }
        } else {
            self.enableEdit()
            sender.setTitle("Save", forState: UIControlState.Normal)
            self.edit = true
            
        }
    }
    
    func getImage() {
        var imageID: String!
        
        let incomeRef = firebaseRef.child("rebate").child(User.currentUserId()!).child(rebReceipt!.category).child("imageID")
        incomeRef.observeEventType(.Value, withBlock:  { (snapshot) in
            if let imageDict = snapshot.value as? [String: Bool] {
                for (index, _) in imageDict {
                    imageID = index
                    self.printImage(imageID)
                }
            }
        })
        
    }
    
    func printImage(imageID: String) {
        let imageRef = firebaseRef.child("image").child(imageID)
        imageRef.observeEventType(.Value, withBlock: { (snapshot) in
            if let imageDict = snapshot.value as? [String: AnyObject] {
                let  url = imageDict["imageUrl"] as! String
                let imageurl = NSURL(string: url)
                self.rebateImageView.sd_setImageWithURL(imageurl)
                
            }
        })
    }
    
    func updateRebate() {
        guard let date = dateTextField.text, let rebateType = rebateTypeTextField.text, let receiptNo = receiptNoTextField.text, let amountString = amountTextField.text, let amount = Double(amountString), let receiptID = rebReceipt?.key else { return }
        
        let receiptRef = firebaseRef.child("receipt").child(receiptID)
        let receiptDict: [String: AnyObject] = ["date": date, "receipt no": receiptNo, "amount": amount, "category": rebateType]
        receiptRef.updateChildValues(receiptDict)
        
        let amountDiff = amount - (rebReceipt?.amount)!
        
        var newTotal = Double()
        let rebateCatRef = firebaseRef.child("RebateCategories").child(rebateType).child("subtotal")
        
        let rebateRef = firebaseRef.child("rebate").child(User.currentUserId()!).child(rebateType)
        rebateRef.observeSingleEventOfType(.Value, withBlock:  { (snapshot) in
            if var rebateTypeDict = snapshot.value as? [String: AnyObject] {
                if let oldValue = rebateTypeDict["subtotal"] as? Double {
                    rebateTypeDict["subtotal"] = oldValue + amountDiff
                    newTotal = oldValue + amountDiff
                } else {
                    rebateTypeDict["subtotal"] = amountDiff
                    newTotal = amountDiff
                }
                
                rebateCatRef.child(User.currentUserId()!).setValue(newTotal)
                rebateRef.updateChildValues(rebateTypeDict)
            }
        })
        
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        activeTextField = textField
        
        self.view.frame = CGRectMake(0, -300, 320, 700)
        
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
    //
    //    func textFieldDidEndEditing(textField: UITextField) {
    //        activeTextField = nil
    //    }
    

    
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
    
    
    func enableEdit () {
        self.dateTextField.userInteractionEnabled = true
        self.receiptNoTextField.userInteractionEnabled = true
        self.amountTextField.userInteractionEnabled = true
        
        self.dateTextField.backgroundColor = UIColor.whiteColor()
        self.receiptNoTextField.backgroundColor = UIColor.whiteColor()
        self.amountTextField.backgroundColor = UIColor.whiteColor()
        
    }
    
    func disableEdit () {
        self.dateTextField.userInteractionEnabled = false
        self.rebateTypeTextField.userInteractionEnabled = false
        self.receiptNoTextField.userInteractionEnabled = false
        self.amountTextField.userInteractionEnabled = false
        
        let color = UIColor(red: 250/255, green: 250/255, blue: 250/255, alpha: 1)
        
        self.dateTextField.backgroundColor = color
        self.rebateTypeTextField.backgroundColor = color
        self.receiptNoTextField.backgroundColor = color
        self.amountTextField.backgroundColor = color
        
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
    
    
}
