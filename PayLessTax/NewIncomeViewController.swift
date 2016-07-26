//
//  NewIncomeViewController.swift
//  PayLessTax
//
//  Created by Sheena Moh on 19/07/2016.
//  Copyright © 2016 SMoh. All rights reserved.
//

import UIKit
import Firebase

class NewIncomeViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    let firebaseRef = FIRDatabase.database().reference()
    var lastSubtotal = Int()

    @IBOutlet weak var incomePickerView: UIPickerView!
    
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var refTextField: UITextField!
    @IBOutlet weak var incomeTextField: UITextField!
    @IBOutlet weak var dateTextField: UITextField!
    
    let pickerData = ["Employment", "Rental", "Others"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        incomePickerView.hidden = true
    }
    
    
    @IBAction func onSaveBtnPressed(sender: UIBarButtonItem) {
        self.addIncome()
        self.navigationController?.popViewControllerAnimated(true)
        self.resignFirstResponder()
    }
    
    @IBAction func onAddBtnPressed(sender: UIButton) {
        incomePickerView.hidden = false
        
    }
    
    func addIncome() {
        guard let date = dateTextField.text, let incomeType = incomeTextField.text, let ref = refTextField.text, let amount = amountTextField.text else { return }
        
        var amountAdded = Int()
        if amount != "" {
            amountAdded = Int(amount)!
        }
        
        let receiptID = NSUUID().UUIDString
        
        let receiptRef = firebaseRef.child("receipt").child(receiptID)
        let receiptDict = ["date": date, "reference no": ref, "amount": amountAdded, "category": incomeType]
        receiptRef.setValue(receiptDict)
        
        let incomeRef = firebaseRef.child("income").child(User.currentUserId()!).child(incomeType)
        
        incomeRef.child("receiptID").child(receiptID).setValue(true)
        
        incomeRef.observeSingleEventOfType(.Value, withBlock:  { (snapshot) in
            if var incomeTypeDict = snapshot.value as? [String: AnyObject]{
                if let oldValue = incomeTypeDict["subtotal"] as? Int{
                    incomeTypeDict["subtotal"] = oldValue + amountAdded
                }else{
                    incomeTypeDict["subtotal"] = amountAdded
                }
                incomeRef.updateChildValues(incomeTypeDict)
            }

        })
        
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.incomeTextField.text = pickerData[row]
        incomePickerView.hidden = true
    }
    
}
