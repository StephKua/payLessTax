//
//  EditIncViewController.swift
//  PayLessTax
//
//  Created by Sheena Moh on 25/07/2016.
//  Copyright © 2016 SMoh. All rights reserved.
//

import UIKit
import Firebase

class EditIncViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var incomeTypeTextField: UITextField!
    @IBOutlet weak var refTextField: UITextField!
    @IBOutlet weak var amountTextField: UITextField!
    var incReceipt: Receipt?
    
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var receiptImageView: UIImageView!

    var strDate: String = ""
    var datePicker = UIDatePicker()
    
    var edit = false
    var firebaseRef = FIRDatabase.database().reference()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTapped()
        
        guard let title = incReceipt?.category, let date = incReceipt?.date, let incomeType = incReceipt?.category, let ref = incReceipt?.refNo, let amount = incReceipt?.amount else { return }
        
        self.disableEdit()
        getImage()
        self.title = title
        self.dateTextField.text = date
        self.incomeTypeTextField.text = incomeType
        self.refTextField.text = ref
        self.amountTextField.text = "\(amount)"
        
    }

    
    @IBAction func onEditBtnPressed(sender: UIButton) {
        
        if edit == true {
            self.disableEdit()
            sender.setTitle("Edit", forState: UIControlState.Normal)
            self.edit = false
            self.updateIncome()
            
        } else {
            self.enableEdit()
            sender.setTitle("Save", forState: UIControlState.Normal)
            self.edit = true
            
        }
    }
    
    func getImage() {
        var imageID: String!
        
        let incomeRef = firebaseRef.child("income").child(User.currentUserId()!).child(incReceipt!.category).child("imageID")
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
                self.receiptImageView.sd_setImageWithURL(imageurl)
                
            }
        })
    }
    
    
    func updateIncome() {
        guard let date = dateTextField?.text, let incomeType = incomeTypeTextField.text, let ref = refTextField.text, let amountString = amountTextField.text, let amount = Int(amountString), let receiptID = incReceipt?.key else { return }
        
        let receiptRef = firebaseRef.child("receipt").child(receiptID)
        let receiptDict: [String:AnyObject] = ["date": date, "reference no": ref, "amount": amount, "category": incomeType]
        receiptRef.updateChildValues(receiptDict)
        
        
        let amountDiff = amount - (incReceipt?.amount)!
        
        let incomeRef = firebaseRef.child("income").child(User.currentUserId()!).child(incomeType)
        incomeRef.observeSingleEventOfType(.Value, withBlock:  { (snapshot) in
            if var incomeTypeDict = snapshot.value as? [String: AnyObject] {
                if let oldValue = incomeTypeDict["subtotal"] as? Int {
                    incomeTypeDict["subtotal"] = oldValue + amountDiff
                } else {
                    incomeTypeDict["subtotal"] = amountDiff
                }
                incomeRef.updateChildValues(incomeTypeDict)
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
//        self.incomeTypeTextField.userInteractionEnabled = true
        self.refTextField.userInteractionEnabled = true
        self.amountTextField.userInteractionEnabled = true
        
        self.dateTextField.backgroundColor = UIColor.whiteColor()
//        self.incomeTypeTextField.backgroundColor = UIColor.whiteColor()
        self.refTextField.backgroundColor = UIColor.whiteColor()
        self.amountTextField.backgroundColor = UIColor.whiteColor()

    }
    
    func disableEdit () {
        self.dateTextField.userInteractionEnabled = false
        self.incomeTypeTextField.userInteractionEnabled = false
        self.refTextField.userInteractionEnabled = false
        self.amountTextField.userInteractionEnabled = false
        
        let color = UIColor(red: 250/255, green: 250/255, blue: 250/255, alpha: 1)
        
        self.dateTextField.backgroundColor = color
        self.incomeTypeTextField.backgroundColor = color
        self.refTextField.backgroundColor = color
        self.amountTextField.backgroundColor = color
        
    }
    
}
