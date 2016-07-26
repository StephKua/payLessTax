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
    
    var edit = false
    var firebaseRef = FIRDatabase.database().reference()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let title = incReceipt?.category, let date = incReceipt?.date, let incomeType = incReceipt?.category, let ref = incReceipt?.refNo, let amount = incReceipt?.amount else { return }
        
        self.disableEdit()
        
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
    
    
    func updateIncome() {
        guard let date = dateTextField?.text, let incomeType = incomeTypeTextField.text, let ref = refTextField.text, let amount = amountTextField.text, let receiptID = incReceipt?.key else { return }
        
        let receiptRef = firebaseRef.child("receipt").child(receiptID)
        let receiptDict = ["date": date, "reference no": ref, "amount": amount, "category": incomeType]
        receiptRef.setValue(receiptDict)
        print(receiptDict)
        
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        textField.layer.borderColor = UIColor.blueColor().CGColor
        print("editing")
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        textField.layer.borderColor = UIColor.clearColor().CGColor
        print("stopped editing")
        self.editBtn.setTitle("hello", forState: UIControlState.Normal)
    }
    
    func enableEdit () {
        self.dateTextField.userInteractionEnabled = true
        self.incomeTypeTextField.userInteractionEnabled = true
        self.refTextField.userInteractionEnabled = true
        self.amountTextField.userInteractionEnabled = true
        
        self.dateTextField.backgroundColor = UIColor.whiteColor()
        self.incomeTypeTextField.backgroundColor = UIColor.whiteColor()
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
