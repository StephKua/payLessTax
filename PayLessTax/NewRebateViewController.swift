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

class NewRebateViewController: UIViewController, UITextFieldDelegate {
    
    var selectedRebate = String()
    var lastSubtotal = Int()
    let firebaseRef = FIRDatabase.database().reference()
    var strDate: String = ""
    
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var receiptTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = selectedRebate
        
    }
    
    func handleDatePicker(sender: UIDatePicker) {
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        strDate = dateFormatter.stringFromDate(sender.date)
        
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        let inputView = UIView(frame: CGRectMake(0, 200, view.frame.width, 200))
        inputView.backgroundColor = UIColor.whiteColor()
        
        let datePicker = UIDatePicker(frame: CGRectMake(10, 10, view.frame.width, 200))
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
        
        handleDatePicker(datePicker)
        dateTextField.inputView = inputView
        dateTextField.inputAccessoryView = toolbar
        
        
    }
    
    func donePicker() {
        dateTextField.resignFirstResponder()
        self.dateTextField.text = strDate
    }
    
    func cancelPicker() {
        dateTextField.resignFirstResponder()
    }
    
    @IBAction func onSaveBtnPressed(sender: UIBarButtonItem) {
        self.addRebate()
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    func addRebate() {
        guard let date = dateTextField.text, let receiptNo = receiptTextField.text, let amount = amountTextField.text else { return }
        
        var amountAdded = Int()
        if amount != "" {
            amountAdded = Int(amount)!
        }
        
        let receiptID = NSUUID().UUIDString
        
        let receiptRef = firebaseRef.child("receipt").child(receiptID)
        let receiptDict = ["date": date, "receipt no": receiptNo, "amount": amountAdded, "category": selectedRebate]
        receiptRef.setValue(receiptDict)
        
        
        let rebateRef = firebaseRef.child("rebate").child(User.currentUserId()!).child(selectedRebate)
        rebateRef.child("receiptID").child(receiptID).setValue(true)
        
        rebateRef.observeSingleEventOfType(.Value, withBlock:  { (snapshot) in
            if var rebateTypeDict = snapshot.value as? [String: AnyObject] {
                if let oldValue = rebateTypeDict["subtotal"] as? Int {
                    rebateTypeDict["subtotal"] = oldValue + amountAdded
                } else {
                    rebateTypeDict["subtotal"] = amountAdded
                }
                rebateRef.updateChildValues(rebateTypeDict)
            }
        })
    }
    
}

