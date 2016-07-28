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
    
    var edit = false
    var firebaseRef = FIRDatabase.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let title = rebReceipt?.category, let date = rebReceipt?.date, let rebateType = rebReceipt?.category, let receiptNo = rebReceipt?.receiptNo, let amount = rebReceipt?.amount else { return }
        
        self.disableEdit()
        
        self.title = title
        self.dateTextField.text = date
        self.rebateTypeTextField.text = rebateType
        self.receiptNoTextField.text = receiptNo
        self.amountTextField.text = "\(amount)"
        
        datePicker = UIDatePicker(frame: CGRectMake(10, 10, view.frame.width, 200))
        
    }

    @IBAction func onEditBtnPressed(sender: UIButton) {
        if edit == true {
            self.disableEdit()
            sender.setTitle("Edit", forState: UIControlState.Normal)
            self.edit = false
            self.updateRebate()
            
        } else {
            self.enableEdit()
            sender.setTitle("Save", forState: UIControlState.Normal)
            self.edit = true
            
        }
    }
    
    
    func updateRebate() {
        guard let date = dateTextField.text, let rebateType = rebateTypeTextField.text, let receiptNo = receiptNoTextField.text, let amountString = amountTextField.text, let amount = Int(amountString), let receiptID = rebReceipt?.key else { return }
        
        let receiptRef = firebaseRef.child("receipt").child(receiptID)
        let receiptDict: [String: AnyObject] = ["date": date, "receipt no": receiptNo, "amount": amount, "category": rebateType]
        receiptRef.updateChildValues(receiptDict)
        print(receiptDict)
        
        let amountDiff = amount - (rebReceipt?.amount)!
        
        let rebateRef = firebaseRef.child("rebate").child(User.currentUserId()!).child(rebateType)
        rebateRef.observeSingleEventOfType(.Value, withBlock:  { (snapshot) in
            if var rebateTypeDict = snapshot.value as? [String: AnyObject] {
                if let oldValue = rebateTypeDict["subtotal"] as? Int {
                    rebateTypeDict["subtotal"] = oldValue + amountDiff
                } else {
                    rebateTypeDict["subtotal"] = amountDiff
                }
                rebateRef.updateChildValues(rebateTypeDict)
            }
        })
        
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
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
//        self.rebateTypeTextField.userInteractionEnabled = true
        self.receiptNoTextField.userInteractionEnabled = true
        self.amountTextField.userInteractionEnabled = true
        
        self.dateTextField.backgroundColor = UIColor.whiteColor()
//        self.rebateTypeTextField.backgroundColor = UIColor.whiteColor()
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

    
}
